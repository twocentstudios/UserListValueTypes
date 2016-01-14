//
//  Created by Christopher Trott on 1/14/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

import Foundation

struct User {
    let name: String
    let avatarURL: NSURL
}

extension User: Equatable {}
func ==(lhs: User, rhs: User) -> Bool {
    return lhs.name == rhs.name &&
        lhs.avatarURL == rhs.avatarURL
}
