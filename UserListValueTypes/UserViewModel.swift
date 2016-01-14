//
//  Created by Christopher Trott on 1/14/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

import Foundation

struct UserViewModel {
    let user: User
    let name: String
    let avatarImageData: NSData?
}

extension UserViewModel: Identifiable {}
func =~=(lhs: UserViewModel, rhs: UserViewModel) -> Bool {
    return lhs.user == rhs.user
}
