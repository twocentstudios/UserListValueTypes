//
//  Created by Christopher Trott on 1/14/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

import Foundation
import ReactiveCocoa

class UsersViewModel {
    var userViewModels: [UserViewModel]? = nil
    
    private let userController: UserController
    private let imageController: ImageController
    
    private let fetchUserViewModelsAction: Action<Void, [UserViewModel], NoError>

    let reloadSignal: Signal<Void, NoError>
    private let reloadObserver: Observer<Void, NoError>
    
    let reloadIndexPathsSignal: Signal<[NSIndexPath], NoError>
    private let reloadIndexPathsObserver: Observer<[NSIndexPath], NoError>
    
    let viewModelsQueue = QueueScheduler(qos: QOS_CLASS_USER_INITIATED, name: "com.twocentstudios.UserList.viewmodels")
    let workQueue = QueueScheduler(qos: QOS_CLASS_DEFAULT, name: "com.twocentstudios.UserList.work")
    let imageQueue = QueueScheduler(qos: QOS_CLASS_DEFAULT, name: "com.twocentstudios.UserList.image")
    
    init(userController: UserController, imageController: ImageController) {
        self.userController = userController
        self.imageController = imageController
        
        (reloadSignal, reloadObserver) = Signal<Void, NoError>.pipe()
        (reloadIndexPathsSignal, reloadIndexPathsObserver) = Signal<[NSIndexPath], NoError>.pipe()
        
        fetchUserViewModelsAction = Action { [unowned workQueue] _ in
            return SignalProducer(value: 100)
                .observeOn(workQueue)
                .flatMap(.Latest, transform: userController.fetchRandomUsersProducer)
                .map { (users: [User]) -> [UserViewModel] in
                    return users.map { user in
                        return UserViewModel(user: user)
                    }
                }
        }
        
        fetchUserViewModelsAction.values
            .observeOn(viewModelsQueue)
            .observeNext { [unowned self] userViewModels in
                self.userViewModels = userViewModels
                self.reloadObserver.sendNext()
            }
    }
    
    func fetchUserViewModels() {
        fetchUserViewModelsAction.apply().start()
    }
    
    func activateIndexPath(indexPath: NSIndexPath) {
        guard let userViewModel = userViewModels?[indexPath.row] else { return }
        if userViewModel.shouldFetchAvatarImage() {
            self.loadUserViewModelImageProducer(userViewModel).start()
        }
    }
    
    private func loadUserViewModelImageProducer(userViewModel: UserViewModel) -> SignalProducer<(UserViewModel, [UserViewModel], [NSIndexPath]), NoError> {
        return SignalProducer<UserViewModel, NoError>(value: userViewModel)
            .observeOn(workQueue)
            .flatMap(FlattenStrategy.Latest, transform: self.loadingImageUserViewModelImageProducer)
            .observeOn(viewModelsQueue)
            .flatMap(.Latest, transform: { [unowned self] viewModel -> SignalProducer<(UserViewModel, [UserViewModel], [NSIndexPath]), NoError> in
                guard let userViewModels = self.userViewModels else { return .empty }
                return self.replaceUserViewModelProducer(viewModel, userViewModels: userViewModels)
            })
            .on(next: { [unowned self] (userViewModel, userViewModels, changedIndexPaths) in
                self.userViewModels = userViewModels
                self.reloadIndexPathsObserver.sendNext(changedIndexPaths)
            })
            .observeOn(imageQueue)
            .map { (viewModel: UserViewModel, _, _) in return viewModel }
            .flatMap(.Latest, transform: self.fetchUserViewModelImageProducer)
            .observeOn(viewModelsQueue)
            .flatMap(.Latest, transform: { [unowned self] (viewModel: UserViewModel) -> SignalProducer<(UserViewModel, [UserViewModel], [NSIndexPath]), NoError> in
                guard let userViewModels = self.userViewModels else { return .empty }
                return self.replaceUserViewModelProducer(viewModel, userViewModels: userViewModels)
            })
            .on(next: { [unowned self] (_, userViewModels, changedIndexPaths) in
                self.userViewModels = userViewModels
                self.reloadIndexPathsObserver.sendNext(changedIndexPaths)
            })
    }
    
    private func fetchUserViewModelImageProducer(userViewModel: UserViewModel) -> SignalProducer<UserViewModel, NoError> {
        return SignalProducer(value: userViewModel.avatarImageData.input)
            .observeOn(self.imageQueue)
            .flatMap(.Latest, transform: imageController.loadImageDataProducer)
            .map(userViewModel.withData)
            .flatMapError { SignalProducer(value: userViewModel.withError($0)) }
    }
    
    private func loadingImageUserViewModelImageProducer(userViewModel: UserViewModel) -> SignalProducer<UserViewModel, NoError> {
        return SignalProducer(value: userViewModel)
            .map { $0.withLoading(0) }
    }
    
    private func replaceUserViewModelProducer(userViewModel: UserViewModel, userViewModels: [UserViewModel]) -> SignalProducer<(UserViewModel, [UserViewModel], [NSIndexPath]), NoError> {
        return SignalProducer(value: (userViewModel, userViewModels))
            .map { (userViewModel, userViewModels) in
                let newUserViewModelsAndIndicies = userViewModels.enumerate().map { (index, oldUserViewModel) -> (Int?, UserViewModel) in
                    if oldUserViewModel =~= userViewModel {
                        return (index, userViewModel)
                    }
                    return (nil, oldUserViewModel)
                }
                let newUserViewModels = newUserViewModelsAndIndicies.map { $0.1 }
                let changedIndicies = newUserViewModelsAndIndicies.map { $0.0 }.flatMap { $0 }
                let changedIndexPaths = changedIndicies.map { NSIndexPath(forRow: $0, inSection: 0) }
                return (userViewModel, newUserViewModels, changedIndexPaths)
        }
    }

}