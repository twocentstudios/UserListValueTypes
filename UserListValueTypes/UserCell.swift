//
//  Created by Christopher Trott on 1/14/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    static let reuseIdentifier = "UserCell"
    
    let avatarImageView: UIImageView
    let activityIndicatorView: UIActivityIndicatorView

    var userViewModel: UserViewModel? {
        didSet {
            self.textLabel?.text = userViewModel?.name ?? ""
            self.avatarImageView.image = userViewModel.flatMap { viewModel in
                switch viewModel.avatarImageData.output {
                case .Empty: return UIImage(named: "placeholder")
                case .Error: return nil
                case .Loaded(let data): return UIImage(data: data)
                case .Loading: return nil
                }
            }
            
            self.avatarImageView.backgroundColor = userViewModel.flatMap { viewModel in
                switch viewModel.avatarImageData.output {
                case .Empty: return .whiteColor()
                case .Error: return .redColor()
                case .Loaded: return .whiteColor()
                case .Loading: return .grayColor()
                }
            }
            
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
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .White)
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
        let height = CGRectGetHeight(self.bounds)
        self.avatarImageView.frame = CGRect(x: 0, y: 0, width: height, height: height)
        self.textLabel!.frame = CGRect(x: height, y: 0, width: 200, height: height)
        self.activityIndicatorView.sizeToFit()
        self.activityIndicatorView.center = self.avatarImageView.center
    }
}
