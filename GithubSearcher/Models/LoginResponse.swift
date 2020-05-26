//
//  LoginResponse.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/26/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import Foundation

struct LoginResponse {
    typealias CompletionWithResponse = (Result<Data, NetworkError>, HTTPURLResponse?) -> Void
    private static let pageSize = 100
    private static var endpoint: URL = {
        var urlC = URLComponents()
        urlC.scheme = "https"
        urlC.host = "api.github.com"
        return urlC.url!
    }()
    
    static func validateCredentials(networkManager: NetworkManager, user: String, password: String, callback: @escaping CompletionWithResponse) {
        let credentials = "\(user):\(password)"
        networkManager.getDataFrom(url: endpoint.absoluteString, credentials: credentials) { (result, response) in
            callback(result, response)
        }
    }
}
