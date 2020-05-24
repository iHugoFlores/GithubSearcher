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
    
    func getDataFrom(url: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        guard let parsedURL = URL(string: url) else {
            fatalError("Invalid URL string: \(url)")
        }
        networkHandler.getData(url: parsedURL) { (data, response, error) in
            if let error = error as NSError?, error.domain == NSURLErrorDomain {
                switch error.code {
                case NSURLErrorNotConnectedToInternet:
                    completion(Result.failure(.deviceOffline))
                default:
                    completion(Result.failure(.unexpectedError(error)))
                }
                return
            }
            guard let response = response as? HTTPURLResponse else {
                completion(Result.failure(.noResponseError))
                return
            }
            if response.statusCode != 200 {
                completion(Result.failure(.serverError))
                return
            }
            guard let data = data else {
                completion(Result.failure(.emptyResult))
                return
            }
            completion(Result.success(data))
        }
    }
}
