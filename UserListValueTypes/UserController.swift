//
//  Created by Christopher Trott on 1/14/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

import Foundation
import ReactiveCocoa
import LoremIpsum

/// UserController is the data source for User objects. The underlying data source could be disk, network, etc.
///
/// In this architecture, Controller objects obscure the data source from the ViewModel layer and provide
/// a consistent interface. Controller objects cannot access members of the View or ViewModel layers.
///
/// UserController is a reference-type because it may implement its own layer of caching.
class UserController {
    /// Asynchronous fetch.
    func fetchRandomUsersProducer(count: Int = 100) -> SignalProducer<[User], NoError> {
        return SignalProducer { observer, disposable in
            observer.sendNext(UserController.fetchRandomUsers(count))
            observer.sendCompleted()
        }
        // .delay(2, onScheduler: QueueScheduler()) /// Simulate a network delay.
    }
    
    /// Generate the specified number of random User objects.
    private static func fetchRandomUsers(count: Int) -> [User] {
        return (0..<count).map { i in
            let name = LoremIpsum.name()
            let avatarURL = NSURL(string: "http://dummyimage.com/96x96/000/fff.jpg&text=\(i)")!
            let user = User(name: name, avatarURL: avatarURL)
            return user
        }
    }
}
