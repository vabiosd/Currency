//
//  MockCurrencyConversionEndpoint.swift
//  Currency Converter
//
//  Created by vaibhav singh on 29/11/22.
//

import Foundation

struct MockCurrencyConversionEndpoint: NetworkEndpointProtocol {
    let path: String = Bundle.main.path(forResource: "MockConversionData", ofType: "json") ?? ""
}
