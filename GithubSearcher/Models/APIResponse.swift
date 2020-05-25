//
//  APIResponse.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/25/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import Foundation

struct APIResponse {
    let rateLimit: Int
    let remaining: Int
    let rateReset: Double
    
    init(headers: [AnyHashable: Any]?) {
        guard let headers = headers else {
            rateLimit = -1
            remaining = -1
            rateReset = 0
            return
        }
        rateLimit = Int(headers["X-Ratelimit-Limit"] as? String ?? "-1")!
        remaining = Int(headers["X-Ratelimit-Remaining"] as? String ?? "-1")!
        rateReset = Double(headers["X-Ratelimit-Reset"] as? String ?? "0")!
    }
}
