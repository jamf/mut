//
//  jsonBuilder.swift
//  MUT
//
//  Created by Michael Levenick on 7/9/19.
//  Copyright © 2019 Levenick Enterprises, LLC. All rights reserved.
//

import Foundation
import SwiftyJSON

public class jsonManager {

    let logMan = logManager()

    public func buildJson(versionLock: Int, serialNumbers: [String]) -> Data{
        // Array & Dictionary
        var jsonToReturn: Data? = "".data(using: .utf8)
        let json: JSON =  ["serialNumbers": serialNumbers, "versionLock": versionLock]
        print(json.description)
        do {
            // Parse the JSON to return token and Expiry
            jsonToReturn = try json.rawData()
        } catch let error as NSError {
            NSLog("[ERROR ]: Failed to get data from jsonToReturn" + error.debugDescription)
            logMan.errorWrite(logString: "Failed to get data from jsonToReturn" + error.debugDescription)
        }
        return jsonToReturn ?? "".data(using: .utf8)!
    }
}
