//
//  NetworkProtocol.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/24/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import Foundation

public enum NetworkError: Error {
    case unexpectedError(Error)
    case emptyResult
    case deviceOffline
    case rateLimitReached
    case serverError
    case noResponseError
}

protocol NetworkProtocol {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    func getData(url: URL, completion: @escaping CompletionHandler)
}
