//
//  CurrencyConversionViewModel.swift
//  Currency Converter
//
//  Created by vaibhav singh on 29/11/22.
//

import Foundation
import RxCocoa
import RxSwift

/// Enum describing different states of the ViewController
enum CurrentConversionState {
    case loading
    case loaded
    /// Error faced while fetching currencies itself
    case errorFetchingCurrencies(String)
    /// Error faced while doing conversion
    case errorDoingConversion(String)
}

final class CurrencyConversionViewModel {
    
    struct UIInputs {
        let baseCurrency: Driver<String>
        let conversionCurrency: Driver<String>
        let amount: Driver<String>
    }
    
    let networkManager: NetworkManagerProtocol
    
    /// ViewModel UI inputs
    let uiInputs: UIInputs
   
    /// ViewModel ViewController outputs
    private(set) var currencies: Observable<[String]>!
    let stateRelay = BehaviorRelay(value: CurrentConversionState.loading)
    private(set) var convertedAmount: Observable<String>!
   
    
    init(uiInputs: UIInputs, networkManager: NetworkManagerProtocol) {
        self.uiInputs = uiInputs
        self.networkManager = networkManager
        
        bindOutput()
    }
    
    private func bindOutput() {
        /// Network call to get available currencies
        currencies = networkManager.getDataModels(endpoint: SymbolsEndpoint())
            .flatMap{ (result: Result<CurrencySymbols, APIError>) -> Observable<[String]> in
                switch result {
                case .success(let currencySymbols):
                    self.stateRelay.accept(.loaded)
                    return Observable.of(currencySymbols.currencies)
                case .failure(let error):
                    self.stateRelay.accept(.errorFetchingCurrencies(error.rawValue))
                    return Observable.of([])
                }
            }
        
        /// Network call to get converted amount
        convertedAmount = Observable.combineLatest(uiInputs.conversionCurrency.asObservable(),
                                                   uiInputs.baseCurrency.asObservable(),
                                                   uiInputs.amount.asObservable()) { conversionCurrency, baseCurrency, amount -> CurrencyConversionEndpoint  in
            return CurrencyConversionEndpoint(toCurrency: conversionCurrency, fromCurrency: baseCurrency, amount: amount)
        }
                                                   .flatMap { endpoint -> Observable<Result<ConvertedCurrency,APIError>> in
                                                       self.stateRelay.accept(.loading)
                                                       return self.networkManager.getDataModels(endpoint: endpoint)
                                                   }.flatMap{ (result: Result<ConvertedCurrency,APIError>) -> Observable<String> in
                                                       switch result {
                                                       case .success(let convertedAmount):
                                                           self.stateRelay.accept(.loaded)
                                                           return Observable.of("\(convertedAmount.result)")
                                                       case .failure(let error):
                                                           self.stateRelay.accept(.errorDoingConversion(error.rawValue))
                                                           return Observable.empty()
                                                       }
                                                   }
    }
}
