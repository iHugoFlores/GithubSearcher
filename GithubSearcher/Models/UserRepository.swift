//
//  UserRepository.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/25/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import Foundation

struct UserRepository: Codable {
    let name: String
    let htmlURL: String
    let stargazersCount: Int
    let forksCount: Int
    
    private enum CodingKeys: String, CodingKey {
        case name
        case htmlURL = "html_url"
        case stargazersCount = "stargazers_count"
        case forksCount = "forks_count"
    }
}

extension UserRepository {
    typealias Completion = (Result<[Self], NetworkError>) -> Void
    typealias CompletionWithResponse = (Result<[Self], NetworkError>, HTTPURLResponse?) -> Void
    private static let pageSize = 100
    private static var endpoint: URL = {
        var urlC = URLComponents()
        urlC.scheme = "https"
        urlC.host = "api.github.com"
        urlC.path = "/users"
        return urlC.url!
    }()

    static func loadDummyResponse(callback: @escaping Completion) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            let data: [Self] = JSONUtil.load(name: "UserRepositories")
            callback(Result.success(data))
        }
    }
    
    static func getUserRepos(networkManager: NetworkManager, user: String, page: Int, callback: @escaping CompletionWithResponse) {
        guard var urlC = URLComponents(url: endpoint, resolvingAgainstBaseURL: true) else { return }
        urlC.path += "/\(user)/repos"
        urlC.queryItems = Self.getQueryParameters(page: page)
        guard let url = urlC.url else { return }
        print(url)
        networkManager.getRESTDataFrom(url: url) { (result: Result<[Self], NetworkError>, response) in
            callback(result, response)
        }
    }
    
    private static func getQueryParameters(page: Int) -> [URLQueryItem] {
        return [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(pageSize))
        ]
    }
}
