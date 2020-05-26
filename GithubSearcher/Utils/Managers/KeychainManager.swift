//
//  KeychainManager.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/26/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import Foundation

class KeychainManager {
    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unhandledError(status: OSStatus)
    }
    
    static func deletePassword(service: String, account: String) throws {
        let query = KeychainManager.keychainQuery(withService: service, account: account)
        let status = SecItemDelete(query as CFDictionary)
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }
    
    static func getPassword(service: String, account: String) throws -> String {
        var query = KeychainManager.keychainQuery(withService: service, account: account)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        
        guard let existingItem = item as? [String : Any],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8)
        else { throw KeychainError.unexpectedPasswordData }
        return password
    }
    
    static func savePassword(_ password: String, withService service: String, account: String) throws {
        var query = KeychainManager.keychainQuery(withService: service, account: account)
        let encodedPassword = password.data(using: String.Encoding.utf8)!
        query[kSecValueData as String] = encodedPassword
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    }

    private static func keychainQuery(withService service: String, account: String) -> [String : Any] {
        var query = [String : Any]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service
        query[kSecAttrAccount as String] = account
        return query
    }
}
