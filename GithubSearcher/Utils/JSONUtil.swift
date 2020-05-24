//
//  JSONUtil.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/23/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import Foundation

struct JSONUtil {
    static func load<T>(name: String) -> T where T: Decodable {
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
    
    static func jsonToObject<T>(json: String) -> T where T: Decodable {
        do {
            let data = Data(json.utf8)
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error {
            fatalError("Error decoding JSON \(json): \(error)")
        }
    }

    static func objectToJSON<T>(object: T) -> String where T: Encodable {
        do {
            let jsonData = try JSONEncoder().encode(object)
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            fatalError("Could not convert structure to JSON")
        }
    }
}
