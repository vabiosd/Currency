//
//  CurrencyConversionEndpoint.swift
//  Currency Converter
//
//  Created by vaibhav singh on 29/11/22.
//

import Foundation

/// Endpoint to get a value converted from one currency to another
final class CurrencyConversionEndpoint: NetworkEndpointProtocol {
    var path: String = "/fixer/convert"
    
    let toCurrency: String
    let fromCurrency: String
    let amount: String
    
    init(toCurrency: String, fromCurrency: String, amount: String){
        self.toCurrency = toCurrency
        self.fromCurrency = fromCurrency
        self.amount = amount
    }
    
    var urlParams: [String : String?] {
        return ["to": toCurrency,
                "from": fromCurrency,
                "amount": amount]
    }
}
