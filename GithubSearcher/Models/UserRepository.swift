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
    static func loadDummyResponse(callback: @escaping Completion) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            let data: [Self] = JSONUtil.load(name: "UserRepositories")
            callback(Result.success(data))
        }
    }
}
