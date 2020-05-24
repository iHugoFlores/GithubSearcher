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
    typealias Completion = (Result<Self, Error>) -> Void
    static func loadDummyResponse(callback: @escaping Completion) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            let data: Self = JSONUtil.load(name: "UsersResponse")
            callback(Result.success(data))
        }
    }
}
