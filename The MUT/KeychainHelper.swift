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
        
        // When deleting old credentials, only care if it's another MUT password.
        let deleteQuery: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrLabel as String: KeyVars.label,
                                    kSecAttrApplicationTag as String: KeyVars.tag]
        
        // When saving, care about everything.
        let saveQuery: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: username,
                                    kSecAttrServer as String: server,
                                    kSecAttrComment as String: "Server: \(server)",
                                    kSecAttrLabel as String: KeyVars.label,
                                    kSecAttrApplicationTag as String: KeyVars.tag,
                                    kSecValueData as String: passData]
        
        // Delete old credentials before re-saving new, valid credentials.
        SecItemDelete(deleteQuery as CFDictionary)
        
        // Save the new credentials that are confirmed-good.
        let status  = SecItemAdd(saveQuery as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status)}
    }
    
    class func load() throws {
        // Build the query for what to find
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrLabel as String: KeyVars.label,
                                    kSecAttrApplicationTag as String: KeyVars.tag,
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
                                    kSecAttrLabel as String: KeyVars.label,
                                    kSecAttrApplicationTag as String: KeyVars.tag,
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
    static let label = "com.jamf.mut.credentials"
    static let tag = label.data(using: .utf8)!
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
