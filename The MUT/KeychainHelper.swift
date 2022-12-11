//
//  KeychainHelper.swift
//  MUT
//
//  Created by Michael Levenick on 11/29/22.
//  Copyright © 2022 Levenick Enterprises LLC. All rights reserved.
//

import Foundation

class KeyChainHelper {

    class func save(username: String, password: String, server: String) throws {
        let passData = password.data(using: String.Encoding.utf8)!
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: username,
                                    kSecAttrServer as String: server,
                                    kSecAttrComment as String: "Server: \(server)",
                                    kSecAttrLabel as String: KeyVars.key, // This is the key we will to find it later
                                    kSecValueData as String: passData]
        SecItemDelete(query as CFDictionary)
        let status  = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status)}
    }
    
    class func load() throws {
        // Build the query for what to find
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrLabel as String: KeyVars.key, // Looking to match this key
                                    kSecMatchLimit as String: kSecMatchLimitOne, // Limiting to one result
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        
        guard let existingItem = item as? [String : Any],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8),
            let username = existingItem[kSecAttrAccount as String] as? String,
            let server = existingItem[kSecAttrServer as String] as? String
        else {
            throw KeychainError.unexpectedPasswordData
        }
        Credentials.server = server
        Credentials.password = password
        Credentials.username = username
    }
    
    class func delete() throws {
        
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrLabel as String: KeyVars.key, // Looking to match this key
                                    kSecMatchLimit as String: kSecMatchLimitOne, // Limiting to one result
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    }

    class func createUniqueID() -> String {
        let uuid: CFUUID = CFUUIDCreate(nil)
        let cfStr: CFString = CFUUIDCreateString(nil, uuid)

        let swiftString: String = cfStr as String
        return swiftString
    }
}

public struct KeyVars {
    static var key = "com.jamf.mut.credentials"
}

public struct Credentials {
    static var username:  String?
    static var password: String?
    static var server: String?
    static var base64Encoded: String?
}

public struct Token {
    static var value: String?
    static var expiration: Int?
    static var data: Data?
}

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}
