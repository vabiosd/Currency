//
//  APIManagerProtocol.swift
//  Currency Converter
//
//  Created by vaibhav singh on 28/11/22.
//

import Foundation
import RxSwift

/// A protocol used to fetch data from the network, we can easily mock this to fetch data from a local file for unit testing networking!
protocol APIManagerProtocol {
    func getData(fromEndpoint endpoint: NetworkEndpointProtocol) -> Observable<Result<Data, APIError>>
}

class APIManager: APIManagerProtocol {
    func getData(fromEndpoint endpoint: NetworkEndpointProtocol) -> Observable<Result<Data, APIError>> {
        return Observable.create{ observer in
            guard let urlRequest = endpoint.getNetworkRequest() else {
                observer.onNext(.failure(.badRequest))
                observer.onCompleted()
                return Disposables.create()
            }
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                /// checking for client side error
                if let _ = error {
                    observer.onNext(.failure(.networkError))
                    observer.onCompleted()
                } else if let httpResponse = response as? HTTPURLResponse, !(200..<300 ~= httpResponse.statusCode) {
                    /// checking if the httpResponse is in successful range
                    observer.onNext(.failure(.badResponse))
                    observer.onCompleted()
                } else if let data = data {
                    /// unwrapping data object if available
                    observer.onNext(.success(data))
                    observer.onCompleted()
                } else {
                    observer.onNext(.failure(.badResponse))
                    observer.onCompleted()
                }
            }.resume()
            return Disposables.create()
        }
    }
}
