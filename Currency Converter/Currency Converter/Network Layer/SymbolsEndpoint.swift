//
//  SymbolsEndpoint.swift
//  Currency Converter
//
//  Created by vaibhav singh on 28/11/22.
//

import Foundation

/// Endpoint to fetch available currencies
final class SymbolsEndpoint: NetworkEndpointProtocol {
    var path: String = "/fixer/symbols"
}
