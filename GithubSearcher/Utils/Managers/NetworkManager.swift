//
//  NetworkManager.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/24/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import UIKit

class NetworkManager {
    private var networkHandler: NetworkProtocol
    
    init(networkHandler: NetworkProtocol) {
        self.networkHandler = networkHandler
    }
    
    func getRESTDataFrom<T>(url: URL, completion: @escaping (Result<T, NetworkError>, HTTPURLResponse?) -> Void) where T: Decodable {
        getDataFrom(url: url.absoluteString) { (result, response) in
            switch result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    completion(Result.success(decoded), response)
                } catch let error {
                    completion(Result.failure(.unexpectedError(error)), response)
                }
            case .failure(let error):
                completion(Result.failure(error), response)
            }
        }
    }
    
    func getDataFrom(url: String, completion: @escaping (Result<Data, NetworkError>, HTTPURLResponse?) -> Void) {
        guard let parsedURL = URL(string: url) else {
            fatalError("Invalid URL string: \(url)")
        }
        networkHandler.getData(url: parsedURL) { (data, response, error) in
            if let error = error as NSError?, error.domain == NSURLErrorDomain {
                switch error.code {
                case NSURLErrorNotConnectedToInternet:
                    completion(Result.failure(.deviceOffline), nil)
                default:
                    completion(Result.failure(.unexpectedError(error)), nil)
                }
                return
            }
            guard let response = response as? HTTPURLResponse else {
                completion(Result.failure(.noResponseError), nil)
                return
            }
            if response.statusCode != 200 {
                completion(Result.failure(self.getSpecificServerError(from: response)), response)
                return
            }
            guard let data = data else {
                completion(Result.failure(.emptyResult), response)
                return
            }
            completion(Result.success(data), response)
        }
    }
    
    private func getSpecificServerError(from response: HTTPURLResponse) -> NetworkError {
        let errorCode = response.statusCode
        switch errorCode {
        case 403:
            return .rateLimitReached
        default:
            return .serverError
        }
    }
}
