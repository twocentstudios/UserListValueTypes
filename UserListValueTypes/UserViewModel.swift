//
//  Created by Christopher Trott on 1/14/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

import Foundation

struct UserViewModel {
    let user: User
    let name: String
    let avatarImageData: NSData?
    
    init(user: User, avatarImageData: NSData?) {
        self.user = user
        self.name = user.name
        self.avatarImageData = avatarImageData
    }
    
    func shouldFetchImage() -> Bool {
        return avatarImageData == nil
    }
}

extension UserViewModel: Identifiable {}
func =~=(lhs: UserViewModel, rhs: UserViewModel) -> Bool {
    return lhs.user == rhs.user
}
