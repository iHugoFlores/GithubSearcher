//
//  NetworkEngine.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/24/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import Foundation

class NetworkEngine: NetworkProtocol {
    func getData(url: URL, completion: @escaping CompletionHandler) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
