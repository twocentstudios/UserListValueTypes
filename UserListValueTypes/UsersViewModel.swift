//
//  Created by Christopher Trott on 1/14/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

import Foundation
import ReactiveCocoa

class UsersViewModel {
    private let userController: UserController
    private let imageController: ImageController
    
    var userViewModels: [UserViewModel]? = nil
    
    private let fetchUserViewModelsAction: Action<Void, [UserViewModel], NSError>
    
    let reloadSignal: Signal<Void, NoError>
    private let reloadObserver: Observer<Void, NoError>
    
    let reloadIndexPathSignal: Signal<NSIndexPath, NoError>
    private let reloadIndexPathObserver: Observer<NSIndexPath, NoError>
    
    init(userController: UserController, imageController: ImageController) {
        self.userController = userController
        self.imageController = imageController
        
        (reloadSignal, reloadObserver) = Signal<Void, NoError>.pipe()
        (reloadIndexPathSignal, reloadIndexPathObserver) = Signal<NSIndexPath, NoError>.pipe()
        
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
            .startOn(QueueScheduler())
        }
        
        fetchUserViewModelsAction.values.observeNext { [weak self] userViewModels in
            self?.userViewModels = userViewModels
            self?.reloadObserver.sendNext()
        }
    }
    
    func fetchUserViewModels() {
        fetchUserViewModelsAction.apply().start()
    }
    
    func activateIndexPath(indexPath: NSIndexPath) {
        // TODO
    }
}