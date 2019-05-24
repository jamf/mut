//
//  popPrompt.swift
//  The MUT
//
//  Created by Michael Levenick on 4/17/17.
//  Copyright © 2017 Levenick Enterprises LLC. All rights reserved.
//

import Cocoa
import Foundation

public class popPrompt {
    
    var globalCSVString: String!
    
    
    // Generate a generic warning message for invalid credentials etc
    public func generalWarning(question: String, text: String) -> Bool {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlert.Style.warning
        myPopup.addButton(withTitle: "OK")
        return myPopup.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
    }
    
    // Generate a specific prompt to ask for credentials
    public func selectDelim (question: String, text: String) -> Bool {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlert.Style.warning
        myPopup.addButton(withTitle: "Use Comma")
        myPopup.addButton(withTitle: "Use Semi-Colon")
        return myPopup.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
    }
    
    // Generate a specific prompt to ask for concurrent runs
    public func selectConcurrent (question: String, text: String) -> Bool {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlert.Style.warning
        myPopup.addButton(withTitle: "2 at a time")
        myPopup.addButton(withTitle: "1 at a time")
        return myPopup.runModal() == NSApplication.ModalResponse.alertSecondButtonReturn
    }
    
    // Browse for a CSV File
    public func browseForCSV() -> String {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["csv"]
        openPanel.begin { (result) in
            if result.rawValue == NSFileHandlingPanelOKButton {
                //print(openPanel.URL!) //uncomment for debugging
                let globalPathToCSV = openPanel.url! as NSURL?
                //print(self.globalPathToCSV.path!) //uncomment for debugging
                self.globalCSVString = globalPathToCSV?.path!
            }
        }
        return globalCSVString
    }
}
