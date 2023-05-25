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
    
    public func buildScopeUpdatesJson(versionLock: Int, serialNumbers: [String]) -> Data{
        // Array & Dictionary
        var jsonToReturn: Data? = "".data(using: .utf8)
        let json: JSON =  ["serialNumbers": serialNumbers, "versionLock": versionLock]
        do {
            // Parse the JSON to return token and Expiry
            jsonToReturn = try json.rawData()
        } catch let error as NSError {
            //NSLog("[ERROR ]: Failed to get data from jsonToReturn" + error.debugDescription)
            logMan.writeLog(level: .error, logString: "Failed to get data from jsonToReturn" + error.debugDescription)
        }
        return jsonToReturn ?? "".data(using: .utf8)!
    }
    
    public func buildMobileDeviceUpdatesJson(data: [String]) -> Data {
        let jsonEncoder = JSONEncoder()
        var encodeMobileDevice: Data? = "".data(using: .utf8)
        let mobileDeviceUpdate = getMobileDeviceUpdateObject(data: data)
        
        do {
            encodeMobileDevice = try jsonEncoder.encode(mobileDeviceUpdate)
        } catch let error as NSError {
            //NSLog("[ERROR ]: Failed to get data from jsonEncoder" + error.debugDescription)
            logMan.writeLog(level: .error, logString: "Failed to get data from jsonEncoder" + error.debugDescription)
        }
        return encodeMobileDevice ?? "".data(using: .utf8)!
    }
    
    func getMobileDeviceUpdateObject(data: [String]) -> MobileDeviceV2 {
        var mobileDeviceUpdate = MobileDeviceV2()
        
        mobileDeviceUpdate.name = data[1].isEmpty ? nil : data[1]
        mobileDeviceUpdate.enforceName = Bool(data[2].lowercased())
        
        return mobileDeviceUpdate
    }
}
