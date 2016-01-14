//
//  Created by Christopher Trott on 1/8/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

import Foundation

protocol Identifiable {
    func =~=(lhs: Self, rhs: Self) -> Bool
}

infix operator =~= { associativity none precedence 130 }

func =~=<T : Identifiable>(lhs: [T], rhs: [T]) -> Bool {
    if lhs.count != rhs.count { return false }
    
    let zipped = Zip2Sequence(lhs, rhs)
    let mapped = zipped.map { (lElement, rElement) -> Bool in
        return lElement =~= rElement
    }
    let reduced = mapped.reduce(true) { (element, result) -> Bool in
        return element && result
    }
    return reduced
}
