//
//  Created by Christopher Trott on 1/14/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

import Foundation

/// UserViewModel is a value type that contains the static data prepared for consumption by the view layer.
/// The avatarImageData field represents an external image resource in various states (empty, loading, loaded, errored).
/// As a value-type, in order to change states, a completely new UserViewModel must be created.
struct UserViewModel {
    
    /// The underlying model object that this view model represents.
    /// This attribute is considered invisible to the View layer of the application.
    let user: User
    
    let name: String
    let avatarImageData: AsyncResource<NSURL, NSData>
    
    /// Convenience initializer for creating a view model from a User model and no other data.
    init(user: User) {
        self.init(user: user, avatarImageData: AsyncResource(input: user.avatarURL, output: AsyncResourceState.Empty))
    }
    
    /// Designated initalizer.
    init(user: User, avatarImageData: AsyncResource<NSURL, NSData>) {
        self.user = user
        self.name = user.name
        self.avatarImageData = avatarImageData
    }
    
    func shouldFetchAvatarImage() -> Bool {
        return avatarImageData.shouldFetch()
    }
    
    /// TODO: These mutators would probably be better as lenses.
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

/// We consider UserViewModels to be of equal identity if their underlying User models are the equal.
extension UserViewModel: Identifiable {}
func =~=(lhs: UserViewModel, rhs: UserViewModel) -> Bool {
    return lhs.user == rhs.user
}
