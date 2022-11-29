//
//  AppCoordinator.swift
//  Currency Converter
//
//  Created by vaibhav singh on 29/11/22.
//

import Foundation
import UIKit

/// A protocol describing the signature of a coordinator used to extract navigation code out of viewControllers thus making viewControllers independent of each other
protocol Coordinator {
    var navigationController: UINavigationController { get }
    func start()
}


/// AppCoordinator responsible for starting the flow of the app by initialising and presenting the initial TimelineViewController
final class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    /// Function used to initialise a viewController with all its dependencies and push it on the navigationController
    func start() {
        let currencyConversionViewController = CurrencyConversionViewController()
        let networkManager = NetworkManager(apiManager: APIManager())
        currencyConversionViewController.viewModelFactory = { uiInputs -> CurrencyConversionViewModel in
            let viewModel = CurrencyConversionViewModel(uiInputs: uiInputs,
                                                        networkManager: networkManager)
            return viewModel
        }
        navigationController.pushViewController(currencyConversionViewController, animated: true)
    }
    
    
}
