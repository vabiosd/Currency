//
//  NetworkManager.swift
//  Currency Converter
//
//  Created by vaibhav singh on 28/11/22.
//

import Foundation
import RxSwift

/// Protocol used to fetch data using a generic endpoint returning a generic data model
protocol NetworkManagerProtocol {
    func getDataModels<T: Decodable>(endpoint: NetworkEndpointProtocol) -> Observable<Result<T, APIError>>
}

/// A concrete reusable NetworkManager class extracting data from different endpoints
final class NetworkManager: NetworkManagerProtocol {
    
    let apiManager: APIManagerProtocol
    var disposeBag = DisposeBag()
    
    init(apiManager: APIManagerProtocol = APIManager()) {
        self.apiManager = apiManager
    }
    
    func getDataModels<T>(endpoint: NetworkEndpointProtocol) -> Observable<Result<T, APIError>> where T : Decodable {
        return apiManager.getData(fromEndpoint: endpoint)
            .map { result -> Result<T, APIError> in
                switch result {
                case .success(let data):
                    let jsonDecoder = JSONDecoder()
                    do {
                        let model = try jsonDecoder.decode(T.self, from: data)
                        return .success(model)
                    } catch {
                        print(error)
                        return .failure(.badResponse)
                    }
                case .failure(let error):
                    return .failure(error)
                }
            }
    }
}
