//
//  NetworkEngine.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/24/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import Foundation

class NetworkEngine: NetworkProtocol {
    func getData(url: URL, withAuth: String?, completion: @escaping CompletionHandler) {
        var urlRequest = URLRequest(url: url)
        if let credentials = withAuth {
            let loginData = credentials.data(using: String.Encoding.utf8)!
            let base64LoginString = loginData.base64EncodedString()
            urlRequest.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        }
        URLSession.shared.dataTask(with: urlRequest, completionHandler: completion).resume()
    }
    
    func getData(url: URL, completion: @escaping CompletionHandler) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
