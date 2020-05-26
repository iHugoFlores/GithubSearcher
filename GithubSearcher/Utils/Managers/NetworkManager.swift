//
//  NetworkManager.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/24/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import UIKit

class NetworkManager {
    typealias DataCompletion = (Result<Data, NetworkError>, HTTPURLResponse?) -> Void
    var networkHandler: NetworkProtocol

    init(networkHandler: NetworkProtocol) {
        self.networkHandler = networkHandler
    }

    func getRESTDataFrom<T>(url: URL, completion: @escaping (Result<T, NetworkError>, HTTPURLResponse?) -> Void) where T: Decodable {
        getDataFrom(url: url.absoluteString) { self.handleRESTResponse(result: $0, response: $1, completion: completion) }
    }
    
    func getRESTDataFrom<T>(url: URL, credentials: String, completion: @escaping (Result<T, NetworkError>, HTTPURLResponse?) -> Void) where T: Decodable {
        getDataFrom(url: url.absoluteString, credentials: credentials) { self.handleRESTResponse(result: $0, response: $1, completion: completion) }
    }
    
    private func handleRESTResponse<T>(result: Result<Data, NetworkError>, response: HTTPURLResponse?, completion: @escaping (Result<T, NetworkError>, HTTPURLResponse?) -> Void) where T: Decodable {
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

    func getDataFrom(url: String, completion: @escaping DataCompletion) {
        guard let parsedURL = URL(string: url) else {
            fatalError("Invalid URL string: \(url)")
        }
        networkHandler.getData(url: parsedURL) { self.handleResponse(data: $0, response: $1, error: $2, completion: completion) }
    }

    func getDataFrom(url: String, credentials: String?, completion: @escaping DataCompletion) {
        guard let parsedURL = URL(string: url) else {
            fatalError("Invalid URL string: \(url)")
        }
        networkHandler.getData(url: parsedURL, withAuth: credentials) { self.handleResponse(data: $0, response: $1, error: $2, completion: completion) }
    }

    private func handleResponse(data: Data?, response: URLResponse?, error: Error?, completion: @escaping DataCompletion) {
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

    private func getSpecificServerError(from response: HTTPURLResponse) -> NetworkError {
        let errorCode = response.statusCode
        switch errorCode {
        case 401: return .unauthorized
        case 403: return .rateLimitReached
        default: return .serverError
        }
    }
}
