//
//  JSONUtil.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/23/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import Foundation

struct JSONUtil {
    static func load<T>(name: String) -> T where T: Codable {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
            fatalError("No JSON file named \(name)")
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error {
            fatalError("Error decoding the JSON file \(name): \(error)")
        }
    }
}
