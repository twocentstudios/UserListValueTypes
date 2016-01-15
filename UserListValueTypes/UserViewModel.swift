//
//  Created by Christopher Trott on 1/14/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

import Foundation

struct UserViewModel {
    let user: User
    let name: String
    let avatarImageData: AsyncResource<NSURL, NSData>
    
    init(user: User) {
        self.init(user: user, avatarImageData: AsyncResource(input: user.avatarURL, output: AsyncResourceState.Empty))
    }
    
    init(user: User, avatarImageData: AsyncResource<NSURL, NSData>) {
        self.user = user
        self.name = user.name
        self.avatarImageData = avatarImageData
    }
    
    func shouldFetchAvatarImage() -> Bool {
        return avatarImageData.shouldFetch()
    }
    
    func withData(data: NSData) -> UserViewModel {
        let resource = self.avatarImageData.withOutput(.Loaded(data))
        let loadedUserViewModel = UserViewModel(user: self.user, avatarImageData: resource)
        return loadedUserViewModel
    }
    
    func withError(error: NSError) -> UserViewModel {
        let resource = self.avatarImageData.withOutput(.Error(error))
        let errorUserViewModel = UserViewModel(user: self.user, avatarImageData: resource)
        return errorUserViewModel
    }
    
    func withLoading(progress: Float) -> UserViewModel {
        let resource = self.avatarImageData.withOutput(.Loading(progress))
        let loadingUserViewModel = UserViewModel(user: self.user, avatarImageData: resource)
        return loadingUserViewModel
    }
}

extension UserViewModel: Identifiable {}
func =~=(lhs: UserViewModel, rhs: UserViewModel) -> Bool {
    return lhs.user == rhs.user
}
