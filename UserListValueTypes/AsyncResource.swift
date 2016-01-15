//
//  Created by Christopher Trott on 1/15/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

/// AsyncResource represents an input type that can be transformed into an output type through
/// a few common states.
struct AsyncResource<InputType, OutputType> {
    let input: InputType
    let output: AsyncResourceState<OutputType>
    
    /// Manual lens.
    func withOutput(output: AsyncResourceState<OutputType>) -> AsyncResource {
        return AsyncResource(input: input, output: output)
    }
    
    /// These should probably be defined somewhere else, but we'll consider this a sane default.
    func shouldFetch() -> Bool {
        switch output {
        case .Empty: return true
        case .Loading: return false
        case .Loaded: return false
        case .Error: return false
        }
    }
}

/// The state of our output. A more thorough implementation would also specify a concrete ErrorType.
enum AsyncResourceState<OutputType> {
    case Empty
    case Loading(Float)
    case Loaded(OutputType)
    case Error(ErrorType)
}
