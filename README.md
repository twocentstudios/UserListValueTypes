# UserList - ValueTypes

UserList is an example iOS app concept designed to present architecture decisions as simply as possible. It simulates fetching a list of random "users" with names and fake avatar images and displays them in a table view. Avatar images are only fetched when their cells become active for the first time.

![Screenshot 1](https://github.com/twocentstudios/userlistvaluetypes/blob/master/Marketing/preview-00.gif)

This variant shows MVVM (Model View ViewModel) being used with value-types to represent the "View Data". "View Data" in this context is usually known as a ViewModel that represents a single resource, not a collection of resources.

This variant of the architecture is in contrast to MVVM that uses reference-types as the "View Data". A version of that was previous presented [here](https://github.com/timehop/Userlist) and discussed in more detail in this [blog post](http://twocentstudios.com/2014/06/08/on-mvvm-and-architecture-questions/).

I'd encourage others to create similar projects (similar to [TodoMVC](http://todomvc.com/), in the spirit of encouraging discussion of the pros and cons of various architectures that are often presented in writings. Even this project is only one potential implementation of MVVM architecture with value types.

## About the Source

UserList is built with Swift 2.1 and Xcode 7.3. UserList uses ReactiveCocoa v4 heavily. The source is commented as exhaustively as possible. Many shortcuts were taken in the Controller (data) layer, but they should not affect the rest of the presented architecture.

Opening issues with questions and/or forking is highly encouraged! Or writing UserList in your architecture of choice. Or even writing a scathing blog post about why this architecture should be avoided at all costs.

## Usage

Clone the repo and run `pod install`.

## License

UserList is available under the MIT license. See the LICENSE file for more info.

## About

UserList was created by [Christopher Trott](http://twitter.com/twocentstudios).
