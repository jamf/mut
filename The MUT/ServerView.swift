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

// Protocol to pass back server URL
protocol DataSentURL {
    func userDidEnterURL(serverURL: String)
}


class ServerView: NSViewController {

    func dialogueWarning (question: String, text: String) -> Bool {
        
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlertStyle.warning
        myPopup.addButton(withTitle: "OK")
        return myPopup.runModal() == NSAlertFirstButtonReturn
        
    }

    
    // Declare variable to use for delegate
    var delegateURL: DataSentURL? = nil
    
    // Takes place right before view appears
    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 600, height: 400)
    }
    
    // Declaration of Outlets
    @IBOutlet weak var radioHosted: NSButton!
    @IBOutlet weak var radioPrem: NSButton!
    @IBOutlet weak var txtHosted: NSTextField!
    @IBOutlet weak var txtPrem: NSTextField!
    
    // Declaration of Radio Action
    @IBAction func radioServerType(_ sender: AnyObject) {
        
        // Disable On-Prem if Hosted = TRUE
        if radioHosted.state == 1 {
            txtPrem.isEnabled = false
            txtHosted.isEnabled = true
            txtHosted.becomeFirstResponder()
            
        // Else Disable Hosted if Hosted = FALSE
        } else {
            txtHosted.isEnabled = false
            txtPrem.isEnabled = true
            txtPrem.becomeFirstResponder()
        }
        
    }
    
    // Takes place after view loads
    override func viewDidLoad() {
        
    }
    
    // Dismiss button
    @IBAction func btnDismissServer(_ sender: AnyObject) {
        
        // Pass back URL Delegate Info
        if delegateURL != nil {
            
            // If hosted radio checked and instance filled
            if radioHosted.state == 1 {
                if txtHosted.stringValue != "" {
                    let serverURL = "https://\(txtHosted.stringValue).jamfcloud.com/JSSResource/"
                    delegateURL?.userDidEnterURL(serverURL: serverURL)
                    // Dismiss the server controller
                    self.dismissViewController(self)
                } else {
                    let _ = dialogueWarning(question: "No Server Info", text: "You have selected the option for a hosted Jamf server, but no instance name was entered. Please enter your instance name and try again.")
                }

            }
            
            // If Prem Radio Chekced
            if radioPrem.state == 1 {
                if txtPrem.stringValue != "" {
                    var serverURL = "\(txtPrem.stringValue)/JSSResource/"
                    serverURL = serverURL.replacingOccurrences(of: "//JSSResource", with: "/JSSResource")
                    delegateURL?.userDidEnterURL(serverURL: serverURL)
                    // Dismiss the server controller
                    self.dismissViewController(self)
                } else {
                    let _ = dialogueWarning(question: "No Server Info", text: "You have selected the option for an on prem server, but no server URL was entered. Please enter your instance name and try again.")
                }

            }
        }
        

    }
    

    
}
