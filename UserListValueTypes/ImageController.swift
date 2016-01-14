//
//  Created by Christopher Trott on 1/14/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

import Foundation

class ImageController {
    func loadImageData(url: NSURL) -> NSData? {
        // Don't try this at home
        guard let data = NSData(contentsOfURL: url) else { return nil }
        return data
    }
}