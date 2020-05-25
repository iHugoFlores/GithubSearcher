//
//  GetUsersResponse.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/23/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import Foundation

struct UsersResponse: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [User]

    private enum CodingKeys: String, CodingKey {
        case items
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
    }
}

extension UsersResponse {
    typealias Completion = (Result<Self, NetworkError>) -> Void
    typealias CompletionWithResponse = (Result<Self, NetworkError>, HTTPURLResponse?) -> Void
    private static let pageSize = 100
    private static var endpoint: URLComponents = {
        var urlC = URLComponents()
        urlC.scheme = "https"
        urlC.host = "api.github.com"
        urlC.path = "/search/users"
        return urlC
    }()
    
    static func loadDummyResponse(callback: @escaping Completion) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            let data: Self = JSONUtil.load(name: "UsersResponse")
            callback(Result.success(data))
        }
    }
    
    static func getUsers(networkManager: NetworkManager, query: String, page: Int, callback: @escaping CompletionWithResponse) {
        endpoint.queryItems = Self.getQueryParameters(query: query, page: page)
        guard let url = endpoint.url else { return }
        networkManager.getRESTDataFrom(url: url) { (result: Result<Self, NetworkError>, response) in
            callback(result, response)
        }
    }
    
    private static func getQueryParameters(query: String, page: Int) -> [URLQueryItem] {
        return [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(pageSize))
        ]
    }
}
