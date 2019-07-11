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

    public func generatePrestageURL(baseURL: String, endpoint: String, prestageID: String, jpapiVersion: String) -> URL {
        var instancedURL = baseURL
        if !baseURL.contains(".") {
            instancedURL = "https://" + baseURL + ".jamfcloud.com/"
        }
        var versionEndpoint = ""

        var encodedURL = NSURL(string: "https://null".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)! as URL

        versionEndpoint = "\(jpapiVersion)/"


        let concatURL = instancedURL + "/uapi" + "/" + versionEndpoint + endpoint + "/" + prestageID + "/scope"
        let cleanURL = concatURL.replacingOccurrences(of: "//uapi", with: "/uapi")
        encodedURL = NSURL(string: "\(cleanURL)")! as URL
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
            return 7
        case "computers":
            return 19
        case "mobiledevices":
            return 17
        case "scope":
            return 1
        default:
            return 0
        }
    }
    
    public func endpoint(csvArray: [[String]]) -> String {
        let headerRow = csvArray[0]
        if headerRow.count <= 2 {
            return "scope"
        } else {
            switch headerRow[0] {
            case "Username":
                return "users"
            case "Computer Serial":
                return "computers"
            case "Mobile Device Serial":
                return "mobiledevices"
            default:
                return "Endpoint_Error"
            }
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
    
    //Builds the dictionary for the identifier table on Attributes view
    public func buildID (ofArray: [[String]]) -> [[String: String]] {
        print("Beginning buildID...")
        var dictID: [[String: String]] = []
        let rows = ofArray.count
        var row = 1
        //start at second entry in CSV to skip headers
        var currentRow: [String] = []
        while row < rows {
            currentRow = ofArray[row]
            dictID.append(["csvIdentifier" : currentRow[0]])
            row += 1
        }
        return dictID
    }

    //buildScopes is just a duplicate of buildID that puts in "scopeID" as the key instead. Used on Prestages and Groups view
    public func buildScopes (ofArray: [[String]]) -> [[String: String]] {
        //print("Beginning buildScopes...")
        var dictID: [[String: String]] = []
        let rows = ofArray.count
        var row = 1
        //start at second entry in CSV to skip headers
        var currentRow: [String] = []
        while row < rows {
            currentRow = ofArray[row]
            dictID.append(["scopeID" : currentRow[0]])
            row += 1
        }
        return dictID
    }
    
    
    //Builds a dictionary of all attributes being modified, pairing key-values for every attribute.
    //used for tableMain
    public func buildDict(rowToRead: Int, ofArray: [[String]]) -> [[String : String]] {
        //print("Beginning buildDict using array: \(ofArray)")
        
        //reads in the header row for the keys. Would handle any header row.
        let headerRow = ofArray[0]
        
        //how many attributes are there
        let columns = headerRow.count
        //start at the first attribute
        var column = 0
        
        //Start at first record, skipping header row
        var currentEntry = [""]
        //Will append to the returnArray throughout the loops
        var returnArray: [[ String : String ]] = []
        //print("Number of columns in headerRow: \(columns)")
        //start at first column
        column = 0
        //set row to whatever is input for row to read. Can be hard coded, or we can increment it
        currentEntry = ofArray[rowToRead]
        //go through each column, pairing headerRow for attribute with the value from the row.
        while column < columns {
            //print("Current Entry... \(currentEntry[column])")
            var builderTwo: [String : String] = [:]
            if currentEntry[column] == "" {
                builderTwo = ["tableAttribute" : headerRow[column], "tableValue" : "UNCHANGED!"]
            } else {
                builderTwo = ["tableAttribute" : headerRow[column], "tableValue" : currentEntry[column]]
            }
            returnArray.append(builderTwo)
            column += 1
        }
        return returnArray
    }
    
}

// This allows us to calculate whether or not EA IDs are actually ints
extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
}
