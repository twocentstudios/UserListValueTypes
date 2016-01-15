//
//  Created by Christopher Trott on 1/14/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

import Foundation
import ReactiveCocoa

/// ImageController is the data source for image data.
///
/// We're specifically not vending UIImage from this class as an experiment in order to keep UIKit 
/// out of our ViewModel and Model layers.
///
/// This implementation is extremely bare. In theory, a layer of caching could sit below this class
/// as well as proper networking.
class ImageController {
    func loadImageDataProducer(URL: NSURL) -> SignalProducer<NSData, NSError> {
        return SignalProducer { observer, disposable in
            let simulateRandomFailure = false // (arc4random_uniform(5) == 0)
            if let image = ImageController.loadImageData(URL) where simulateRandomFailure == false {
                observer.sendNext(image)
                observer.sendCompleted()
            } else {
                observer.sendFailed(NSError(domain: "com.twocentstudios.UserList", code: 0, userInfo: [NSLocalizedDescriptionKey: "Image data failed to load."]))
            }
        }
    }
    
    /// Synchronously convert an image URL to data.
    private static func loadImageData(URL: NSURL) -> NSData? {
        // Don't try this at home.
        guard let data = NSData(contentsOfURL: URL) else { return nil }
        return data
    }
}