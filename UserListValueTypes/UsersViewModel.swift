//
//  Created by Christopher Trott on 1/14/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

import Foundation
import ReactiveCocoa

class UsersViewModel {
    
    /// The cononical list of UserViewModels vended to UsersViewController.
    /// Should only be updated on viewModelsQueue.
    var userViewModels: [UserViewModel]? = nil
    
    /// Data source of User objects.
    private let userController: UserController
    
    /// Data source of image data.
    private let imageController: ImageController
    
    /// RAC Action that vends [UserViewModel].
    /// At the moment we assume this will never error, although real requests would handle that case.
    private let fetchUserViewModelsAction: Action<Void, [UserViewModel], NoError>

    /// Signal/Observer pair whose events represent a full reload of userViewModels.
    let reloadSignal: Signal<Void, NoError>
    private let reloadObserver: Observer<Void, NoError>
    
    /// Signal/Observer pair whose events represent a change to some indexPaths.
    let reloadIndexPathsSignal: Signal<[NSIndexPath], NoError>
    private let reloadIndexPathsObserver: Observer<[NSIndexPath], NoError>
    
    /// All updates to userViewModels should be performed on this queue.
    /// TODO: should this be QueueScheduler.mainQueueScheduler because that's where userViewModels is observed?
    let viewModelsQueue = QueueScheduler(qos: QOS_CLASS_USER_INITIATED, name: "com.twocentstudios.UserList.viewmodels")
    
    /// A general queue for performing view model fetching and transformations.
    let workQueue = QueueScheduler(qos: QOS_CLASS_DEFAULT, name: "com.twocentstudios.UserList.work")
    
    /// All image requests run on this queue.
    /// TODO: Figure out how to make this a concurrent queue.
    let imageQueue = QueueScheduler(qos: QOS_CLASS_DEFAULT, name: "com.twocentstudios.UserList.image")
    
    init(userController: UserController, imageController: ImageController) {
        self.userController = userController
        self.imageController = imageController
        
        (reloadSignal, reloadObserver) = Signal<Void, NoError>.pipe()
        (reloadIndexPathsSignal, reloadIndexPathsObserver) = Signal<[NSIndexPath], NoError>.pipe()
        
        fetchUserViewModelsAction = Action { [unowned workQueue] _ in
            /// Fetch 100 User objects on workQueue, then transform them into UserViewModels with empty images.
            return SignalProducer(value: 100)
                .observeOn(workQueue)
                .flatMap(.Latest, transform: userController.fetchRandomUsersProducer)
                .map { (users: [User]) -> [UserViewModel] in
                    return users.map { user in
                        return UserViewModel(user: user)
                    }
                }
        }
        
        /// When new values are vended by fetchUserViewModelsAction, update userViewModels on viewModelsQueue.
        fetchUserViewModelsAction.values
            .observeOn(viewModelsQueue)
            .observeNext { [unowned self] userViewModels in
                self.userViewModels = userViewModels
                self.reloadObserver.sendNext()
            }
    }
    
    /// Load a random set of UserViewModels from the data source.
    func fetchUserViewModels() {
        /// Executes `fetchUserViewModelsAction`, creating a SignalProducer and starting it.
        fetchUserViewModelsAction.apply().start()
    }
    
    /// Informs UsersViewModel that the UserViewModel at indexPath is now "active" aka on screen.
    func activateIndexPath(indexPath: NSIndexPath) {
        guard let userViewModel = userViewModels?[indexPath.row] else { return }
        if userViewModel.shouldFetchAvatarImage() {
            /// If the userViewModel is empty, fetch its image.
            self.loadUserViewModelImageProducer(userViewModel).start()
        }
    }
    
    /// Creates a SignalProducer that first updates the input userViewModel to the loading state, then fetches its image and sends another
    /// userViewModel in the loaded state. It sends a userViewModel in the error state if the image fails to load.
    private func loadUserViewModelImageProducer(userViewModel: UserViewModel) -> SignalProducer<(UserViewModel, [UserViewModel], [NSIndexPath]), NoError> {
        return SignalProducer<UserViewModel, NoError>(value: userViewModel) /// Lift userViewModel into a SignalProducer so it can be scheduled.
            .observeOn(workQueue) /// Do the next part on the workQueue.
            .flatMap(FlattenStrategy.Latest, transform: self.loadingImageUserViewModelImageProducer) /// Transfrom the userViewModel into the loading state.
            .observeOn(viewModelsQueue) /// Do the next part on the viewModels queue.
            .flatMap(.Latest, transform: { [unowned self] viewModel -> SignalProducer<(UserViewModel, [UserViewModel], [NSIndexPath]), NoError> in
                /// Grab the latest userViewModels and replace the ones that have changed.
                guard let userViewModels = self.userViewModels else { return .empty }
                return self.replaceUserViewModelProducer(viewModel, userViewModels: userViewModels)
            })
            .on(next: { [unowned self] (userViewModel, userViewModels, changedIndexPaths) in
                /// Actually replace the userViewModels and alert observers which indexPaths were changed.
                self.userViewModels = userViewModels
                self.reloadIndexPathsObserver.sendNext(changedIndexPaths)
            })
            .observeOn(imageQueue) /// Do the next part on the imageQueue.
            .map { (viewModel: UserViewModel, _, _) in return viewModel } /// We're only interested in the userViewModel.
            .flatMap(.Latest, transform: self.fetchUserViewModelImageProducer) /// Fetch the image.
            .observeOn(viewModelsQueue) /// Do the next part on the viewModels queue.
            .flatMap(.Latest, transform: { [unowned self] (viewModel: UserViewModel) -> SignalProducer<(UserViewModel, [UserViewModel], [NSIndexPath]), NoError> in
                /// Same deal as above, only this time we're replacing the userViewModel loading state with either the loaded or error state.
                guard let userViewModels = self.userViewModels else { return .empty }
                return self.replaceUserViewModelProducer(viewModel, userViewModels: userViewModels)
            })
            .on(next: { [unowned self] (_, userViewModels, changedIndexPaths) in
                self.userViewModels = userViewModels
                self.reloadIndexPathsObserver.sendNext(changedIndexPaths)
            })
    }
    
    /// Fetch the image for userViewModel, then replace it with the loaded or error state of itself.
    private func fetchUserViewModelImageProducer(userViewModel: UserViewModel) -> SignalProducer<UserViewModel, NoError> {
        return SignalProducer(value: userViewModel.avatarImageData.input) /// Lift the URL into a Signal.
            .flatMap(.Latest, transform: imageController.loadImageDataProducer) /// Fetch the image.
            .map(userViewModel.withData) /// Create a new userViewModel with the image data.
            .flatMapError { SignalProducer(value: userViewModel.withError($0)) } /// Or if it failed, catch the error and create a new userViewModel with the error.
    }
    
    /// Send a new userViewModel in the loading state.
    private func loadingImageUserViewModelImageProducer(userViewModel: UserViewModel) -> SignalProducer<UserViewModel, NoError> {
        return SignalProducer(value: userViewModel)
            .map { $0.withLoading(0) }
    }
    
    /// Given a list of userViewModels and a userViewModel, replace those view models in userViewModels that have "equal identity" to userViewModel.
    /// Equal identity is defined by the Identifiable protocol and custom =~= operator.
    /// Equal identity means that the underlying User objects are the equal, but the state of the derived view model attributes (the state of the image loading) are different.
    /// Returns the input userViewModel, updated userViewModels, and an array of indexPaths that were changed.
    private func replaceUserViewModelProducer(userViewModel: UserViewModel, userViewModels: [UserViewModel]) -> SignalProducer<(UserViewModel, [UserViewModel], [NSIndexPath]), NoError> {
        return SignalProducer(value: (userViewModel, userViewModels)) // Lift arguments into Signal.
            .map { (userViewModel, userViewModels) in
                /// For each view model in the array, compare its identity with the input view model.
                /// The reason we compare with don't use indexOf is because if a User object is in the array more than once,
                /// its second instance would never be replaced.
                let newUserViewModelsAndIndicies = userViewModels.enumerate().map { (index, oldUserViewModel) -> (Int?, UserViewModel) in
                    if oldUserViewModel =~= userViewModel {
                        /// Include the index of the userViewModel in the tuple.
                        return (index, userViewModel)
                    }
                    /// Use nil to represent items without equal identity in this context.
                    return (nil, oldUserViewModel)
                }
                
                /// Separate out the userViewModels from the tuple.
                let newUserViewModels = newUserViewModelsAndIndicies.map { $0.1 }
                
                /// Separate out the indicies of the changed items and remove unchanged (nil) values.
                let changedIndicies = newUserViewModelsAndIndicies.map { $0.0 }.flatMap { $0 }
                
                /// Convert indicies to index paths.
                let changedIndexPaths = changedIndicies.map { NSIndexPath(forRow: $0, inSection: 0) }
                
                return (userViewModel, newUserViewModels, changedIndexPaths)
        }
    }

}