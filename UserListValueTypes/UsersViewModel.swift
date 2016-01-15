//
//  Created by Christopher Trott on 1/14/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

import Foundation
import ReactiveCocoa

class UsersViewModel {
    var userViewModels: [UserViewModel]? = nil
    
    private let fetchUserViewModelsAction: Action<Void, [UserViewModel], NoError>
    private let fetchUserViewModelImageProducer: UserViewModel -> SignalProducer<UserViewModel, NoError>
    
    let reloadSignal: Signal<Void, NoError>
    private let reloadObserver: Observer<Void, NoError>
    
    let reloadIndexPathsSignal: Signal<[NSIndexPath], NoError>
    private let reloadIndexPathsObserver: Observer<[NSIndexPath], NoError>
    
    private let viewModelsQueue = QueueScheduler(qos: QOS_CLASS_USER_INITIATED, name: "com.twocentstudios.UserList.viewmodels")
    
    init(userController: UserController, imageController: ImageController) {
        (reloadSignal, reloadObserver) = Signal<Void, NoError>.pipe()
        (reloadIndexPathsSignal, reloadIndexPathsObserver) = Signal<[NSIndexPath], NoError>.pipe()

        let workQueue = QueueScheduler(qos: QOS_CLASS_DEFAULT, name: "com.twocentstudios.UserList.work")
        let imageQueue = QueueScheduler(qos: QOS_CLASS_DEFAULT, name: "com.twocentstudios.UserList.image")

        fetchUserViewModelsAction = Action { _ in
            return SignalProducer(value: 100)
                .observeOn(workQueue)
                .flatMap(.Latest, transform: userController.fetchRandomUsersProducer)
                .map { (users: [User]) -> [UserViewModel] in
                    return users.map { user in
                        return UserViewModel(user: user)
                    }
                }
        }
        
        fetchUserViewModelImageProducer = { userViewModel in
            return SignalProducer(value: userViewModel.avatarImageData.input)
                .observeOn(imageQueue)
                .flatMap(.Latest, transform: imageController.loadImageDataProducer)
                .map(userViewModel.withData)
                .flatMapError { SignalProducer(value: userViewModel.withError($0)) }
        }
        
        fetchUserViewModelsAction.values
            .observeOn(viewModelsQueue)
            .observeNext { [weak self] userViewModels in
                self?.userViewModels = userViewModels
                self?.reloadObserver.sendNext()
            }
    }
    
    func fetchUserViewModels() {
        fetchUserViewModelsAction.apply().start()
    }
    
    func activateIndexPath(indexPath: NSIndexPath) {
        guard let userViewModel = userViewModels?[indexPath.row] else { return }
        if userViewModel.shouldFetchAvatarImage() {
            fetchUserViewModelImageProducer(userViewModel)
                .observeOn(viewModelsQueue)
                .startWithNext { [weak self] userViewModel in
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
    }
    
    
}