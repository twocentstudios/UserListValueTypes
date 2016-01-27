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
    
    let URLSession: NSURLSession
    
    init(URLSession: NSURLSession) {
        self.URLSession = URLSession
    }
    
    func loadImageDataProducer(URL: NSURL) -> SignalProducer<NSData, NSError> {
        let URLSession = self.URLSession
        
        return SignalProducer { observer, disposable in
            let simulateRandomFailure = false // (arc4random_uniform(5) == 0)
            
            if simulateRandomFailure {
                observer.sendFailed(NSError(domain: "com.twocentstudios.UserList", code: 0, userInfo: [NSLocalizedDescriptionKey: "Simulated random image failure."]))
                return
            }
            
            let task = URLSession.dataTaskWithURL(URL) { data, response, error in
                // TODO: check response codes
                
                if let error = error {
                    observer.sendFailed(error)
                    return
                }
                
                if let data = data {
                    observer.sendNext(data)
                    observer.sendCompleted()
                    return
                }
                
                observer.sendFailed(NSError(domain: "com.twocentstudios.UserList", code: 0, userInfo: [NSLocalizedDescriptionKey: "Image data failed to load."]))
            }
            
            disposable.addDisposable { _ in
                task.cancel()
            }

            task.resume()
        }
    }
}