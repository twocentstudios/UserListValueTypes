//
//  Created by Christopher Trott on 1/14/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    static let reuseIdentifier = "UserCell"

    var userViewModel: UserViewModel? {
        didSet {
            self.textLabel?.text = userViewModel?.name ?? ""
            self.imageView?.image = userViewModel?.avatarImageData.flatMap { UIImage(data: $0) }
        }
    }
}
