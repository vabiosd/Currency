FF-1 Convert Currency has been implemented, due to lack of time other user stories could not be implemented.

To run the project, please run pod install in the root directory to install RxSwift related cocoapods!

A few things to note:
1. The network layer is resuable and fully testable, build using RxSwift! Although, the network layer is fully testable, unit testing could not be added to display that due to a lack of time. I have added a few mocks to display how the network layer can be tested by reading from a local disk!
2. The project follows an MVVM-C pattern, the viewModel can be unit tested completely and the coordinator pattern can be build up on help isolate viewControllers!
3. On app start, all available currencies are being fetched, If that call fails, an error is displayed to the user. If given more time I would add a retry button there!
4. On successful fetch of available currencies, user can select to and drom currencies and enter an amount to see the converted value. If the conversion API fails user will see an error and can retry again!
5. ViewModel taken in all the inputs from the ViewController as Driver and provide outputs as Observables, no stop gaps behviour relays are used to drive the API calls.
6. UI is build programmatically using autolayout app scales well to different devices and orientations

Please find a video of the app in action: https://drive.google.com/file/d/1Owk90egNR7GwOCTic_qRUtUquXqWrL3Y/view?usp=share_link


NOTE: 
1. The fixer API key has limited number of requests allowed in free subscription, so the requests might stop working after a few tries (100 API calls).
2. Currently all currencies are displayed which includes cryptocurrencies, in a real app it might make more sense to fetch only certain currencies and display to the user

