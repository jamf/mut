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
    
    let defaultURL = UserDefaults.standard
    
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
        
        // Restore Instance Name if Hosted
        if defaultURL.value(forKey: "HostedInstanceName") != nil {
            txtHosted.stringValue = defaultURL.value(forKey: "HostedInstanceName") as! String
        }
        
        // Restore Prem URL if on prem
        if defaultURL.value(forKey: "PremInstanceURL") != nil {
            txtPrem.stringValue = defaultURL.value(forKey: "PremInstanceURL") as! String
            radioPrem.state = 1
            txtPrem.becomeFirstResponder()
            txtHosted.isEnabled = false
            txtPrem.isEnabled = true
        }
    }
    
    // Dismiss button
    @IBAction func btnDismissServer(_ sender: AnyObject) {
        
        // Pass back URL Delegate Info
        if delegateURL != nil {
            
            // If hosted radio checked and instance filled
            if radioHosted.state == 1 {
                if txtHosted.stringValue != "" {
                    
                    // Add JSS Resource and jamfcloud info
                    let serverURL = "https://\(txtHosted.stringValue).jamfcloud.com/JSSResource/"
                    
                    // Save the hosted instance and wipe saved prem server
                    let instanceName = txtHosted.stringValue
                    delegateURL?.userDidEnterURL(serverURL: serverURL) // Delegate for passing info to main view
                    defaultURL.set(instanceName, forKey: "HostedInstanceName")
                    defaultURL.removeObject(forKey: "PremInstanceURL")
                    defaultURL.synchronize()
                    
                    // Dismiss the server controller
                    self.dismissViewController(self)
                } else {
                    // If no URL is filled, warn user
                    let _ = dialogueWarning(question: "No Server Info", text: "You have selected the option for a hosted Jamf server, but no instance name was entered. Please enter your instance name and try again.")
                }

            }
            
            // If Prem Radio Chekced
            if radioPrem.state == 1 {
                
                // Check if URL is filled
                if txtPrem.stringValue != "" {
                    
                    // Add JSS Resource and remove double slashes
                    var serverURL = "\(txtPrem.stringValue)/JSSResource/"
                    serverURL = serverURL.replacingOccurrences(of: "//JSSResource", with: "/JSSResource")
                    
                    // Save the prem URL and wipe saved hosted names
                    let serverSave = txtPrem.stringValue
                    delegateURL?.userDidEnterURL(serverURL: serverURL) // Delegate for passing info to main view
                    defaultURL.set(serverSave, forKey: "PremInstanceURL")
                    defaultURL.removeObject(forKey: "HostedInstanceName")
                    defaultURL.synchronize()
                    
                    // Dismiss the server controller
                    self.dismissViewController(self)
                    
                } else {
                    // If no URL is filled, warn user
                    let _ = dialogueWarning(question: "No Server Info", text: "You have selected the option for an on prem server, but no server URL was entered. Please enter your instance name and try again.")
                }
            }
        }
    }
}
