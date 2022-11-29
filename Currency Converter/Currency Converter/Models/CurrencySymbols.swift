//
//  CurrencySymbols.swift
//  Currency Converter
//
//  Created by vaibhav singh on 29/11/22.
//

import Foundation

/// A struct to hold the different currencies available
struct CurrencySymbols: Decodable {
    let symbols: [String: String]
    
    var currencies: [String] {
        return symbols.map{ $0.key }
    }
}
