//
//  Created by Christopher Trott on 1/15/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

struct AsyncResource<InputType, OutputType> {
    let input: InputType
    let output: AsyncResourceState<OutputType>
    
    func withOutput(output: AsyncResourceState<OutputType>) -> AsyncResource {
        return AsyncResource(input: input, output: output)
    }
    
    func shouldFetch() -> Bool {
        switch output {
        case .Empty: return true
        case .Loading: return false
        case .Loaded: return false
        case .Error: return true
        }
    }
}

enum AsyncResourceState<OutputType> {
    case Empty
    case Loading(Float)
    case Loaded(OutputType)
    case Error(ErrorType)
}
