//
//  DataManipulation.swift
//  The MUT v5
//
//  Created by Michael Levenick on 5/24/19.
//  Copyright © 2019 Michael Levenick. All rights reserved.
//

import Foundation

public class dataPreparation {
    
    // ******************************************
    // Functions to create URLs can be found here
    // ******************************************
    
    public func generateURL(baseURL: String, endpoint: String, identifierType: String, identifier: String, jpapi: Bool, jpapiVersion: String) -> URL {
        var instancedURL = baseURL
        if !baseURL.contains(".") {
            instancedURL = "https://" + baseURL + ".jamfcloud.com/"
        }
        var versionEndpoint = ""
        var encodedURL = NSURL(string: "https://null".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)! as URL
        if jpapi {
            //JPAPI URLS
            if jpapiVersion != "nil" {
                versionEndpoint = "\(jpapiVersion)/"
            }
            let concatURL = instancedURL + "/uapi" + versionEndpoint + endpoint
            let cleanURL = concatURL.replacingOccurrences(of: "//uapi", with: "/uapi")
            encodedURL = NSURL(string: "\(cleanURL)")! as URL
        } else {
            // CAPI URLS
            let concatURL = instancedURL + "/JSSResource/" + endpoint + "/" + identifierType + "/" + identifier
            var cleanURL = concatURL.replacingOccurrences(of: "//JSSResource", with: "/JSSResource")
            cleanURL = cleanURL.replacingOccurrences(of: "JSSResource//", with: "JSSResource/")
            encodedURL = NSURL(string: "\(cleanURL)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)! as URL
        }
        return encodedURL
    }
    
    // ******************************************
    // Functions to encode/decode data can be found here
    // ******************************************
    
    public func base64Credentials(user: String, password: String) -> String {
        // Concatenate the credentials and base64 encode the resulting string
        let concatCredentials = "\(user):\(password)"
        let utf8Credentials = concatCredentials.data(using: String.Encoding.utf8)
        let base64Credentials = utf8Credentials?.base64EncodedString() ?? "nil"
        return base64Credentials
    }
    
    public func expectedColumns(endpoint: String) -> Int {
        switch endpoint {
        case "users":
            return 6
        case "computers":
            return 17
        case "mobiledevices":
            return 15
        default:
            return 0
        }
    }
    
    public func eaIDs(expectedColumns: Int, numberOfColumns: Int, headerRow: [String]) -> [String] {
        var ea_ids = [String]()
        for i in expectedColumns...(numberOfColumns - 1) {
            let clean_ea_id = headerRow[i].replacingOccurrences(of: "EA_", with: "")
            ea_ids = ea_ids + [clean_ea_id]
            if !clean_ea_id.isInt {
                print("Problem with EA ID field \(i)")
            }
        }
        return ea_ids
    }
    
    public func eaValues(expectedColumns: Int, numberOfColumns: Int, currentRow: [String]) -> [String] {
        var ea_values = [String]()
        for i in expectedColumns...(numberOfColumns - 1) {
            ea_values = ea_values + [currentRow[i]]
        }
        return ea_values
    }
}

// This allows us to calculate whether or not EA IDs are actually ints
extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
}
