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
    let name: String! = nil
    let value: Any? = nil
    let storage: NSButton! = nil
    
    init(name: String!, value: Any?, storage: NSButton!){
        self.name = name
        self.value = value
        self.storage = storage
    }
}
