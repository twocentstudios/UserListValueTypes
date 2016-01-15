//
//  Created by Christopher Trott on 1/14/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

import Foundation
import ReactiveCocoa

class ImageController {
    func loadImageDataProducer(url: NSURL) -> SignalProducer<NSData, NSError> {
        return SignalProducer { observer, disposable in
            if let image = ImageController.loadImageData(url) {
                observer.sendNext(image)
                observer.sendCompleted()
            } else {
                observer.sendFailed(NSError(domain: "", code: 0, userInfo: nil))
            }
        }
    }
    
    private static func loadImageData(url: NSURL) -> NSData? {
        // Don't try this at home
        guard let data = NSData(contentsOfURL: url) else { return nil }
        return data
    }
}