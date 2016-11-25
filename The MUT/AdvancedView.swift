//
//  ServerView.swift
//  The MUT
//
//  Created by Michael Levenick on 10/18/16.
//  Copyright © 2016 Levenick Enterprises LLC. All rights reserved.
//

// SERVER PAGE

import Foundation
import Cocoa


class AdvancedView: NSViewController {
    @IBOutlet weak var txtDelimiter: NSTextField!
    @IBOutlet weak var popUpdateLines: NSPopUpButton!

    // Declare variable for defaults on main view
    let advancedViewDefaults = UserDefaults.standard
    
    @IBAction func btnAccept(_ sender: Any) {
        if txtDelimiter.stringValue != "" {
            advancedViewDefaults.set("\(txtDelimiter.stringValue)", forKey: "Delimiter")
        } else {
            advancedViewDefaults.set(",", forKey: "Delimiter")
        }
        
        advancedViewDefaults.set("\(popUpdateLines.titleOfSelectedItem!)", forKey: "ConcurrentRows")
        
        self.dismiss(self)
    }

    @IBAction func btnCancel(_ sender: Any) {
        self.dismiss(self)
    }

}
