//
//  APIError.swift
//  Currency Converter
//
//  Created by vaibhav singh on 28/11/22.
//

import Foundation

enum APIError: String, Error {
    case badRequest = "Ah something seems broken, please try again later!"
    case networkError = "Your device seems offline!"
    case badResponse = "Our servers are down, please try after some time!"
}
