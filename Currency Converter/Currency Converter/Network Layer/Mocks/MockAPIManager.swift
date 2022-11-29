//
//  MockAPIManager.swift
//  Currency Converter
//
//  Created by vaibhav singh on 29/11/22.
//

import Foundation
import RxSwift

/// A MockAPIManager to demonstrate how networking can be tested, we can inject this into NetworkManager and unit test the viewModel by reading data from a local file!
final class MockAPIManager: APIManagerProtocol {
    func getData(fromEndpoint endpoint: NetworkEndpointProtocol) -> Observable<Result<Data, APIError>> {
        /// Reading the contents of the local JSON file and decoding it into the the ConvertedCurrency struct
        if let data = try? Data(contentsOf: URL(fileURLWithPath: endpoint.path)) {
           return Observable.of(.success(data))
        } else {
            return Observable.of(.failure(.badRequest))
        }
    }
}
