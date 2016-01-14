//
//  Created by Christopher Trott on 1/14/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

import Foundation
import LoremIpsum

class UserController {
    func fetchRandomUsers(count: Int = 100) -> [User] {
        return (0..<count).map { i in
            let name = LoremIpsum.name()
            let avatarURL = NSURL(string: "http://dummyimage.com/96x96/000/fff.jpg&text=\(i)")!
            let user = User(name: name, avatarURL: avatarURL)
            return user
        }
    }
}
