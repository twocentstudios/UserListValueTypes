//
//  Created by Christopher Trott on 1/14/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

import Foundation

struct User {
    let name: String
    let avatarURL: NSURL
}

/// User must conform to equatable in order for our Identifiable protocol in the ViewModel layer to function.
extension User: Equatable {}
func ==(lhs: User, rhs: User) -> Bool {
    return lhs.name == rhs.name &&
        lhs.avatarURL == rhs.avatarURL
}
