//
//  Created by Christopher Trott on 1/14/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

import Foundation
import ReactiveCocoa

class UsersViewModel {
    var userViewModels: [UserViewModel]? = nil
    
    private let fetchUserViewModelsAction: Action<Void, [UserViewModel], NoError>
    private let fetchUserViewModelImageAction: Action<UserViewModel, UserViewModel, NoError>
    
    let reloadSignal: Signal<Void, NoError>
    private let reloadObserver: Observer<Void, NoError>
    
    let reloadIndexPathsSignal: Signal<[NSIndexPath], NoError>
    private let reloadIndexPathsObserver: Observer<[NSIndexPath], NoError>
    
    init(userController: UserController, imageController: ImageController) {
        (reloadSignal, reloadObserver) = Signal<Void, NoError>.pipe()
        (reloadIndexPathsSignal, reloadIndexPathsObserver) = Signal<[NSIndexPath], NoError>.pipe()

        let workQueue = QueueScheduler(qos: QOS_CLASS_DEFAULT, name: "com.twocentstudios.UserList.work")
        let imageQueue = QueueScheduler(qos: QOS_CLASS_DEFAULT, name: "com.twocentstudios.UserList.image")
        let viewModelsQueue = QueueScheduler(qos: QOS_CLASS_USER_INITIATED, name: "com.twocentstudios.UserList.viewmodels")

        fetchUserViewModelsAction = Action { _ in
            return SignalProducer { observer, disposable in
                let users = userController.fetchRandomUsers(100)
                observer.sendNext(users)
                observer.sendCompleted()
            }
            .map { (users: [User]) -> [UserViewModel] in
                return users.map { user in
                    return UserViewModel(user: user, avatarImageData: nil)
                }
            }
            .startOn(workQueue)
        }
        
        fetchUserViewModelImageAction = Action { userViewModel in
            return SignalProducer { observer, disposable in
                let avatarURL = userViewModel.user.avatarURL
                let data = imageController.loadImageData(avatarURL)
                let loadedUserViewModel = UserViewModel(user: userViewModel.user, avatarImageData: data)
                observer.sendNext(loadedUserViewModel)
                observer.sendCompleted()
            }
            .startOn(imageQueue)
        }
        
        fetchUserViewModelsAction.values
            .observeOn(viewModelsQueue)
            .observeNext { [weak self] userViewModels in
                self?.userViewModels = userViewModels
                self?.reloadObserver.sendNext()
            }
        
        fetchUserViewModelImageAction.values
            .observeOn(viewModelsQueue)
            .observeNext { [weak self] userViewModel in
                guard let userViewModels = self?.userViewModels else { return }
                let newUserViewModelsAndIndicies = userViewModels.enumerate().map { (index, oldUserViewModel) -> (Int?, UserViewModel) in
                    if oldUserViewModel =~= userViewModel {
                        return (index, userViewModel)
                    }
                    return (nil, oldUserViewModel)
                }
                let newUserViewModels = newUserViewModelsAndIndicies.map { $0.1 }
                let changedIndicies = newUserViewModelsAndIndicies.map { $0.0 }.flatMap { $0 }
                let changedIndexPaths = changedIndicies.map { NSIndexPath(forRow: $0, inSection: 0) }
                
                self?.userViewModels = newUserViewModels
                self?.reloadIndexPathsObserver.sendNext(changedIndexPaths)
            }
    }
    
    func fetchUserViewModels() {
        fetchUserViewModelsAction.apply().start()
    }
    
    func activateIndexPath(indexPath: NSIndexPath) {
        guard let userViewModel = userViewModels?[indexPath.row] else { return }
        if !userViewModel.shouldFetchImage() { return }
        
        fetchUserViewModelImageAction.apply(userViewModel).start()
    }
}