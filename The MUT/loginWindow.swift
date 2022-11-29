//
//  loginWindow.swift
//  The MUT
//
//  Created by Michael Levenick on 5/28/19.
//  Copyright © 2019 Levenick Enterprises, LLC. All rights reserved.
//

import Cocoa
import Foundation
import SwiftyJSON

// Delegate required to send data forward to the main view controller
protocol DataSentDelegate {
    func userDidAuthenticate(base64Credentials: String, url: String, token: String, expiry: Int)
}

class loginWindow: NSViewController {



    // Declare outlets for use in the interface
    @IBOutlet weak var txtURLOutlet: NSTextField!
    @IBOutlet weak var txtUserOutlet: NSTextField!
    @IBOutlet weak var txtPassOutlet: NSSecureTextField!

    @IBOutlet weak var spinProgress: NSProgressIndicator!

    @IBOutlet weak var btnSubmitOutlet: NSButton!
    @IBOutlet weak var chkRememberMe: NSButton!
    @IBOutlet weak var chkBypass: NSButton!

    // Set up global variables to be used outside functions
    var serverURL: String!
    var base64Credentials: String!
    var verified = false

    // Punctuation character set to be used in cleaning up URLs
    let punctuation = CharacterSet(charactersIn: ".:/")
    
    // Set up defaults to be able to save to and restore from
    let loginDefaults = UserDefaults.standard
    
    // Set up our delegate to pass data forward to the main view
    var delegateAuth: DataSentDelegate? = nil

    // Constructor for our classes to be used
    let tokenMan = tokenManagement()
    let dataPrep = dataPreparation()
    let logMan = logManager()

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
        
        // Restore "Insecure SSL" checkbox settings if we have a default stored
        if loginDefaults.value(forKey: "Insecure") != nil {
            if loginDefaults.bool(forKey: "Insecure") {
                chkBypass.state = NSControl.StateValue(rawValue: 1)
            } else {
                chkBypass.state = NSControl.StateValue(rawValue: 0)
            }
        } else {
            // Just in case you ever want to do something for no default stored
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // Forces the window to be the size we want, not resizable
        preferredContentSize = NSSize(width: 550, height: 550)
        // If we have a URL and a User stored focus the password field
        if loginDefaults.value(forKey: "InstanceURL") != nil  && loginDefaults.value(forKey: "UserName") != nil {
            self.txtPassOutlet.becomeFirstResponder()
        }
    }

    @IBAction func btnSubmit(_ sender: Any) {

        // Clean up whitespace at the beginning and end of the fields, in case of faulty copy/paste
        txtURLOutlet.stringValue = txtURLOutlet.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)
        txtUserOutlet.stringValue = txtUserOutlet.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)

        // Warn the user if they have failed to enter an instancename AND prem URL
        if txtURLOutlet.stringValue == "" {
            _ = popPrompt().noServer()
        }

        // Warn the user if they have failed to enter a username
        if txtUserOutlet.stringValue == "" {
            _ = popPrompt().noUser()
        }

        // Warn the user if they have failed to enter a password
        if txtPassOutlet.stringValue == "" {
            _ = popPrompt().noPass()
        }
        
        Credentials.username = txtUserOutlet.stringValue
        Credentials.password = txtPassOutlet.stringValue
        Credentials.server = txtURLOutlet.stringValue

        // Move forward with verification if we have not flagged the doNotRun flag
        if txtURLOutlet.stringValue != "" && txtPassOutlet.stringValue != "" && txtUserOutlet.stringValue != "" {
            
            // Change the UI to a running state
            guiRunning()

            DispatchQueue.global(qos: .background).async {
                // Get our token data from the API class
                Token.data = self.tokenMan.getToken(url: Credentials.server!, user: Credentials.username!, password: Credentials.password!, allowUntrusted: self.loginDefaults.bool(forKey: "Insecure"))
                DispatchQueue.main.async {
                    print(String(decoding: Token.data!, as: UTF8.self)) // Uncomment for debugging
                    // Reset the GUI and pop up a warning with the info if we get a fatal error
                    if String(decoding: Token.data!, as: UTF8.self).contains("FATAL") {
                        _ = popPrompt().fatalWarning(error: String(decoding: Token.data!, as: UTF8.self))
                        self.guiReset()
                    } else {
                        // No error found leads you here:
                        if String(decoding: Token.data!, as: UTF8.self).contains("token") {
                            // Good credentials here, as told by there being a token
                            self.verified = true

                            do {
                                // Parse the JSON to return token and Expiry
                                let newJson = try JSON(data: Token.data!)
                                Token.value = newJson["token"].stringValue
                                Token.expiration = newJson["expires"].intValue
                            } catch let error as NSError {
                                self.logMan.errorWrite(logString: "Failed to load: \(error.localizedDescription)")
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
                                let base64creds = self.dataPrep.base64Credentials(user: self.txtUserOutlet.stringValue, password: self.txtPassOutlet.stringValue)
                                self.delegateAuth?.userDidAuthenticate(base64Credentials: base64creds, url: self.txtURLOutlet.stringValue, token: Token.value!, expiry: Token.expiration!)
                                self.dismiss(self)
                            }
                        } else {
                            // Bad credentials here
                            DispatchQueue.main.async {
                                self.guiReset()
                                // Popup warning of invalid credentials
                                _ = popPrompt().invalidCredentials()

                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func btnQuit(_ sender: Any) {
        self.dismiss(self)
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func chkBypassAction(_ sender: Any) {
        if chkBypass.state == NSControl.StateValue(rawValue: 1) {
            self.loginDefaults.set(true, forKey: "Insecure")
        } else {
            self.loginDefaults.set(false, forKey: "Insecure")
        }
    }
    
    @IBAction func chkRememberAction(_ sender: Any) {
        if chkRememberMe.state == NSControl.StateValue(rawValue: 1) {
            // Do nothing
        } else {
            
        }
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
