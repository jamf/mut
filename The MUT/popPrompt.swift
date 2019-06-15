//
//  popPrompt.swift
//  The MUT v5
//
//  Created by Michael Levenick on 5/24/19.
//  Copyright © 2019 Michael Levenick. All rights reserved.
//


// THIS IS ALL OLD CODE!!!
// THIS ENTIRE CLASS SHOULD BE REWRITTEN

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
    
    public func invalidCredentials() -> Bool {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = "Invalid Credentials"
        myPopup.informativeText = "The credentials you entered do not seem to have sufficient permissions. This could be due to an incorrect user/password, or possibly from insufficient permissions.\n\nMUT tests this against the user's ability to generate a token for the new JPAPI/UAPI. This token is now required for some tasks that MUT performs."
        myPopup.alertStyle = NSAlert.Style.warning
        myPopup.addButton(withTitle: "OK")
        return myPopup.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
    }
    
    public func noServer() -> Bool {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = "No Server Info"
        myPopup.informativeText = "It appears that you have not entered any information for your Jamf Pro URL. Please enter either a Jamf Cloud instance name, or your full URL if you host your own server."
        myPopup.alertStyle = NSAlert.Style.warning
        myPopup.addButton(withTitle: "OK")
        return myPopup.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
    }
    
    public func noUser() -> Bool {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = "No Username Found"
        myPopup.informativeText = "It appears that you have not entered a username for MUT to use while accessing Jamf Pro. Please enter your username and password, and try again."
        myPopup.alertStyle = NSAlert.Style.warning
        myPopup.addButton(withTitle: "OK")
        return myPopup.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
    }
    
    public func noPass() -> Bool {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = "No Password Found"
        myPopup.informativeText = "It appears that you have not entered a password for MUT to use while accessing Jamf Pro. Please enter your username and password, and try again."
        myPopup.alertStyle = NSAlert.Style.warning
        myPopup.addButton(withTitle: "OK")
        return myPopup.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
    }
    
    public func fatalWarning(error: String) -> Bool {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = "Fatal Error"
        myPopup.informativeText = "The MUT received a fatal error at authentication. The most common cause of this is an incorrect server URL. The full error output is below. \n\n \(error))"
        myPopup.alertStyle = NSAlert.Style.warning
        myPopup.addButton(withTitle: "OK")
        return myPopup.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
    }
    
}
