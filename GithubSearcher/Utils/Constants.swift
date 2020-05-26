//
//  Constants.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/26/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import Foundation

final class Constants {
    final class UserDefaults {
        static let USER = "USER"
        static let PASSWORD = "PASSWORD"
    }

    static let isoDateFormatter: DateFormatter = {
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formater
    }()

    static let dateFormatter: DateFormatter = {
        let formater = DateFormatter()
        formater.dateStyle = .medium
        formater.timeStyle = .none
        return formater
    }()
}
