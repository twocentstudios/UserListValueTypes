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
            let avatarURL = LoremIpsum.URLForPlaceholderImageFromService(.Hhhhold, withSize:CGSize(width: 96, height:96)).URLByAppendingPathComponent("jpg?test=\(i)")
            let user = User(name: name, avatarURL: avatarURL)
            return user
        }
    }
}
