//
//  Created by Christopher Trott on 1/14/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

import UIKit

/// UserCell is intended to be simple in scope.
final class UserCell: UITableViewCell {
    static let reuseIdentifier = "UserCell"
    
    /// The built in imageView is quirky. We'll use our own.
    let avatarImageView: UIImageView
    
    /// activityIndicatorView is annoying but helps visually convey the state changes.
    let activityIndicatorView: UIActivityIndicatorView

    /// Do all cell configuration in userViewModel. This will be set on every state change and reuse.
    var userViewModel: UserViewModel? {
        didSet {
            self.textLabel?.text = userViewModel?.name ?? ""
            
            /// Only set the image for loaded state.
            self.avatarImageView.image = userViewModel.flatMap { viewModel in
                switch viewModel.avatarImageData.output {
                case .Empty: return nil
                case .Error: return nil
                case .Loaded(let data): return UIImage(data: data)
                case .Loading: return nil
                }
            }
            
            /// Background color conveys state changes when not loaded.
            self.avatarImageView.backgroundColor = userViewModel.flatMap { viewModel in
                switch viewModel.avatarImageData.output {
                case .Empty: return UIColor(patternImage: UIImage(named: "placeholder")!)
                case .Error: return .redColor()
                case .Loaded: return .whiteColor()
                case .Loading: return UIColor(patternImage: UIImage(named: "placeholder")!)
                }
            }
            
            /// Show the activityIndicatorView when loading.
            if let viewModel = userViewModel {
                switch viewModel.avatarImageData.output {
                case .Loading: activityIndicatorView.startAnimating()
                default: activityIndicatorView.stopAnimating()
                }
            } else {
                activityIndicatorView.stopAnimating()
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        avatarImageView = UIImageView()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(avatarImageView)
        self.contentView.addSubview(activityIndicatorView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        /// Don't try this at home.
        let height = CGRectGetHeight(self.bounds)
        self.avatarImageView.frame = CGRect(x: 0, y: 0, width: height, height: height)
        self.textLabel!.frame = CGRect(x: height, y: 0, width: 200, height: height)
        self.activityIndicatorView.sizeToFit()
        self.activityIndicatorView.center = self.avatarImageView.center
    }
}
