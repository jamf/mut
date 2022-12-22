//
//  MenuHelper.swift
//  MUT
//
//  Created by Michael Levenick on 12/11/22.
//  Copyright © 2022 Levenick Enterprises LLC. All rights reserved.
//

import Cocoa
import Foundation

public class Setting {
    
    let settingDefaults = UserDefaults.standard
    
    var key: String! = nil
    var value: Any? = nil
    
    init(key: String!, value: Any?){
        self.key = key
        self.value = value
    }
    
    // These singleton values should only be updated on application load and when menu options are clicked
    
    // Standard Defaults Storage
    static var username = Setting(key: "UserName", value: nil)
    static var instanceURL = Setting(key: "InstanceURL", value: nil)
    
    // General Settings
    static var logLevel = Setting(key: "LogLevel", value: nil)
    static var delimiter = Setting(key: "Delimiter", value: nil)
    static var usersInts = Setting(key: "UserInts", value: nil)
    
    // Security Settings
    static var allowUntrustedSSL = Setting(key: "AllowUntrusted", value: nil)
    static var rememberInstance = Setting(key: "RememberInstance", value: nil)
    static var rememberUser = Setting(key: "RememberUser", value: nil)
    
    static let allDefaults = [username,
                              instanceURL,
                              logLevel,
                              delimiter,
                              usersInts,
                              allowUntrustedSSL,
                              rememberInstance,
                              rememberUser]
    
    public func restoreDefaults(){
        for setting in Setting.allDefaults{
            setting.value = settingDefaults.value(forKey: setting.key)
        }
    }
}
