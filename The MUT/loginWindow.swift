//
//  loginWindow.swift
//  The MUT
//
//  Created by Michael Levenick on 5/28/19.
//  Copyright © 2019 Levenick Enterprises LLC. All rights reserved.
//

import Cocoa
import Foundation
import SwiftyJSON

// Delegate required to send data forward to the main view controller
protocol DataSentDelegate {
    func userDidAuthenticate(base64Credentials: String, url: String, token: String, expiry: Int)
}

class loginWindow: NSViewController, URLSessionDelegate {



    // Declare outlets for use in the interface
    @IBOutlet weak var txtURLOutlet: NSTextField!
    @IBOutlet weak var txtUserOutlet: NSTextField!
    @IBOutlet weak var txtPassOutlet: NSSecureTextField!
    @IBOutlet weak var spinProgress: NSProgressIndicator!
    @IBOutlet weak var btnSubmitOutlet: NSButton!
    @IBOutlet weak var chkRememberMe: NSButton!
    @IBOutlet weak var chkBypass: NSButton!

    // Set up global variables to be used outside functions
    var doNotRun: Bool!
    var serverURL: String!
    var base64Credentials: String!
    var token: String!
    var verified = false
    var expiry: Int!

    // Punctuation character set to be used in cleaning up URLs
    let punctuation = CharacterSet(charactersIn: ".:/")
    
    // Set up defaults to be able to save to and restore from
    let loginDefaults = UserDefaults.standard
    
    // Set up our delegate to pass data forward to the main view
    var delegateAuth: DataSentDelegate? = nil

    // Constructor for our classes to be used
    let tokenMan = tokenManagement()
    let dataPrep = dataPreparation()

    // This runs when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()

        // Restore the Username to text box if we have a default stored
        if loginDefaults.value(forKey: "UserName") != nil {
            txtUserOutlet.stringValue = loginDefaults.value(forKey: "UserName") as! String
        }

        // Restore Prem URL to text box if we have a default stored
        if loginDefaults.value(forKey: "InstanceURL") != nil {
            txtURLOutlet.stringValue = loginDefaults.value(forKey: "InstanceURL") as! String
        }

        // Restore "remember me" checkbox settings if we have a default stored
        if loginDefaults.value(forKey: "Remember") != nil {
            if loginDefaults.bool(forKey: "Remember") {
                chkRememberMe.state = NSControl.StateValue(rawValue: 1)
            } else {
                chkRememberMe.state = NSControl.StateValue(rawValue: 0)
            }
        } else {
            // Just in case you ever want to do something for no default stored
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // Forces the window to be the size we want, not resizable
        preferredContentSize = NSSize(width: 450, height: 600)
        // If we have a URL and a User stored focus the password field
        if loginDefaults.value(forKey: "InstanceURL") != nil  && loginDefaults.value(forKey: "UserName") != nil {
            self.txtPassOutlet.becomeFirstResponder()
        }
    }

    @IBAction func btnSubmit(_ sender: Any) {
        doNotRun = false

        // Clean up whitespace at the beginning and end of the fields, in case of faulty copy/paste
        txtURLOutlet.stringValue = txtURLOutlet.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)
        txtUserOutlet.stringValue = txtUserOutlet.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)
        //txtPassOutlet.stringValue = txtPassOutlet.stringValue.trimmingCharacters(in: CharacterSet.whitespaces) // Perhaps we don't want to trim passwords just in case?

        // Warn the user if they have failed to enter an instancename AND prem URL
        if txtURLOutlet.stringValue == "" {
            _ = popPrompt().noServer()
            doNotRun = true // Set Do Not Run flag
        }

        // Warn the user if they have failed to enter a username
        if txtUserOutlet.stringValue == "" {
            _ = popPrompt().noUser()
            doNotRun = true // Set Do Not Run flag
        }

        // Warn the user if they have failed to enter a password
        if txtPassOutlet.stringValue == "" {
            _ = popPrompt().noPass()
            doNotRun = true // Set Do Not Run flag
        }

        // Move forward with verification if we have not flagged the doNotRun flag
        if !doNotRun {
            
            // Change the UI to a running state
            guiRunning()
            
            // Get our token data from the API class
            let tokenData = tokenMan.getToken(url: txtURLOutlet.stringValue, user: txtUserOutlet.stringValue, password: txtPassOutlet.stringValue, allowUntrusted: false)
            //print(String(decoding: tokenData, as: UTF8.self)) // Uncomment for debugging
            // Reset the GUI and pop up a warning with the info if we get a fatal error
            if String(decoding: tokenData, as: UTF8.self).contains("FATAL") {
                _ = popPrompt().fatalWarning(error: String(decoding: tokenData, as: UTF8.self))
                guiReset()
            } else {
                // No error found leads you here:
                if String(decoding: tokenData, as: UTF8.self).contains("token") {
                    // Good credentials here, as told by there being a token
                    self.verified = true
                    //let passedURL = dataPrep.generateURL(baseURL: txtURLOutlet.stringValue, endpoint: "", identifierType: "", identifier: "", jpapi: false, jpapiVersion: "")
                    
                    do {
                        // Parse the JSON to return token and Expiry
                        let newJson = try JSON(data: tokenData)
                        token = newJson["token"].stringValue
                        expiry = newJson["expires"].intValue
                    } catch let error as NSError {
                        NSLog("[ERROR ]: Failed to load: \(error.localizedDescription)")
                    }
                    
                    // Store username if button pressed
                    if self.chkRememberMe.state.rawValue == 1 {
                        self.loginDefaults.set(self.txtUserOutlet.stringValue, forKey: "UserName")
                        self.loginDefaults.set(self.txtURLOutlet.stringValue, forKey: "InstanceURL")
                        self.loginDefaults.set(true, forKey: "Remember")
                        self.loginDefaults.synchronize()
                        
                    } else {
                        self.loginDefaults.removeObject(forKey: "UserName")
                        self.loginDefaults.removeObject(forKey: "InstanceURL")
                        self.loginDefaults.set(false, forKey: "Remember")
                        self.loginDefaults.synchronize()
                    }
                    self.spinProgress.stopAnimation(self)
                    self.btnSubmitOutlet.isHidden = false
                    
                    if self.delegateAuth != nil {

                        // Delegate stuff to pass info forward goes here
                        let base64creds = dataPrep.base64Credentials(user: self.txtUserOutlet.stringValue, password: self.txtPassOutlet.stringValue)
                        self.delegateAuth?.userDidAuthenticate(base64Credentials: base64creds, url: txtURLOutlet.stringValue, token: token, expiry: expiry)
                    
                        self.dismiss(self)
                    }
                } else {
                    // Bad credentials here
                    DispatchQueue.main.async {
                        self.guiReset()
                        // Popup warning of invalid credentials
                        _ = popPrompt().invalidCredentials()
                        if self.chkBypass.state.rawValue == 1 {
                            if self.delegateAuth != nil {
                                // Delegate stuff to pass info forward goes here
                                let base64creds = self.dataPrep.base64Credentials(user: self.txtUserOutlet.stringValue, password: self.txtPassOutlet.stringValue)
                                self.delegateAuth?.userDidAuthenticate(base64Credentials: base64creds, url: self.txtURLOutlet.stringValue, token: self.token, expiry: self.expiry)
                                
                                self.dismiss(self)
                            }
                            self.verified = true
                        }
                    }
                }
            }


        } else {
            // Reset the Do Not Run flag so that on subsequent runs we try the checks again.
            doNotRun = false
        }
    }
    
    @IBAction func btnQuit(_ sender: Any) {
        self.dismiss(self)
        NSApplication.shared.terminate(self)
    }
    
    func guiRunning() {
        btnSubmitOutlet.isHidden = true
        spinProgress.startAnimation(self)
    }
    func guiReset() {
        spinProgress.stopAnimation(self)
        btnSubmitOutlet.isHidden = false
    }
}
