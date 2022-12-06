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

class loginWindow: NSViewController {

    // Declare outlets for use in the interface
    @IBOutlet weak var txtURLOutlet: NSTextField!
    @IBOutlet weak var txtUserOutlet: NSTextField!
    @IBOutlet weak var txtPassOutlet: NSSecureTextField!

    @IBOutlet weak var spinProgress: NSProgressIndicator!

    @IBOutlet weak var btnSubmitOutlet: NSButton!
    @IBOutlet weak var chkRememberMe: NSButton!
    @IBOutlet weak var chkBypass: NSButton!

    // Punctuation character set to be used in cleaning up URLs
    let punctuation = CharacterSet(charactersIn: ".:/")
    
    // Set up defaults to be able to save to and restore from
    let loginDefaults = UserDefaults.standard

    // Instantiating objects
    let tokenMan = tokenManagement()
    let dataPrep = dataPreparation()
    let logMan = logManager()
    
    var keyChainLogin = false

    // This runs when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = NSSize(width: 550, height: 550)
        
        // Attempt to load info from keychain
        do {
            try KeyChainHelper.load()
            self.txtURLOutlet.stringValue = Credentials.server!
            self.txtUserOutlet.stringValue = Credentials.username!
            self.txtPassOutlet.stringValue = Credentials.password!
            self.logMan.infoWrite(logString: "Found credentials stored in KeyChain. Attempting login.")
            keyChainLogin = true
            self.btnSubmit(self)
        } catch KeychainError.noPassword {
            // No info found in keychain
            self.logMan.infoWrite(logString: "No stored info found in KeyChain.")
        } catch KeychainError.unexpectedPasswordData {
            // Info found, but it was bad
            self.logMan.errorWrite(logString: "Information was found in KeyChain, but it was somehow corrupt.")
        } catch {
            // Something else
            self.logMan.fatalWrite(logString: "Unhandled exception found with extracting KeyChain info.")
        }

        // Restore "remember me" checkbox settings if we have a default stored
        if loginDefaults.value(forKey: "Remember") != nil {
            if loginDefaults.bool(forKey: "Remember") {
                chkRememberMe.state = NSControl.StateValue(rawValue: 1)
            } else {
                chkRememberMe.state = NSControl.StateValue(rawValue: 0)
            }
        }
        
        // Restore "Insecure SSL" checkbox settings if we have a default stored
        if loginDefaults.value(forKey: "Insecure") != nil {
            if loginDefaults.bool(forKey: "Insecure") {
                chkBypass.state = NSControl.StateValue(rawValue: 1)
            } else {
                chkBypass.state = NSControl.StateValue(rawValue: 0)
            }
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // Forces the window to be the size we want, not resizable
        preferredContentSize = NSSize(width: 550, height: 550)
    }

    @IBAction func btnSubmit(_ sender: Any) {

        // Clean up whitespace at the beginning and end of the fields, in case of faulty copy/paste
        txtURLOutlet.stringValue = txtURLOutlet.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)
        txtUserOutlet.stringValue = txtUserOutlet.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if self.chkRememberMe.state.rawValue != 1 {
            deleteKeyChain()
        }

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
        Credentials.base64Encoded = self.dataPrep.base64Credentials(user: self.txtUserOutlet.stringValue, password: self.txtPassOutlet.stringValue)

        // Move forward with verification if we have not flagged the doNotRun flag
        if txtURLOutlet.stringValue != "" && txtPassOutlet.stringValue != "" && txtUserOutlet.stringValue != "" {
            
            // Change the UI to a running state
            guiRunning()

            DispatchQueue.global(qos: .background).async {
                // Get our token data from the API class
                Token.data = self.tokenMan.getToken(url: Credentials.server!, user: Credentials.username!, password: Credentials.password!, allowUntrusted: self.loginDefaults.bool(forKey: "Insecure"))
                DispatchQueue.main.async {
                    //print(String(decoding: Token.data!, as: UTF8.self)) // Uncomment for debugging
                    // Reset the GUI and pop up a warning with the info if we get a fatal error
                    if String(decoding: Token.data!, as: UTF8.self).contains("FATAL") {
                        _ = popPrompt().fatalWarning(error: String(decoding: Token.data!, as: UTF8.self))
                        self.guiReset()
                    } else {
                        // No error found leads you here:
                        if String(decoding: Token.data!, as: UTF8.self).contains("token") {
                            // Good credentials here, as told by there being a token
                            do {
                                // Parse the JSON to return token and Expiry
                                let newJson = try JSON(data: Token.data!)
                                Token.value = newJson["token"].stringValue
                                Token.expiration = newJson["expires"].intValue
                                
                                self.dismiss(self)
                            } catch let error as NSError {
                                self.logMan.errorWrite(logString: "Failed to load: \(error.localizedDescription)")
                            }

                            // Store username if button pressed
                            if self.chkRememberMe.state.rawValue == 1 {
                                self.loginDefaults.set(true, forKey: "Remember")
                                self.loginDefaults.synchronize()
                                
                                // Attempt to save the information in keychain
                                self.logMan.infoWrite(logString: "Remember Me checkbox checked. Storing credentials in KeyChain for later use.")
                                DispatchQueue.global(qos: .background).async {
                                    do {
                                        try KeyChainHelper.save(username: Credentials.username!, password: Credentials.password!, server: Credentials.server!)
                                    } catch {
                                        // Issue with saving info to keychain
                                    }
                                }

                            } else {
                                self.loginDefaults.removeObject(forKey: "UserName")
                                self.loginDefaults.removeObject(forKey: "InstanceURL")
                                self.loginDefaults.set(false, forKey: "Remember")
                                self.loginDefaults.synchronize()
                            }
                            self.spinProgress.stopAnimation(self)
                            self.btnSubmitOutlet.isHidden = false
                        } else {
                            // Bad credentials here
                            if self.keyChainLogin {
                                DispatchQueue.main.async {
                                    self.guiReset()
                                    // Popup warning of invalid credentials
                                    _ = popPrompt().invalidKeychain()
                                    self.keyChainLogin = false
                                }
                                self.deleteKeyChain()
                            } else {
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
    
    func deleteKeyChain() {
        DispatchQueue.global(qos: .background).async {
            do {
                try KeyChainHelper.delete()
                self.logMan.infoWrite(logString: "Deleting information stored in keychain.")
            } catch KeychainError.noPassword {
                // No info found in keychain
                self.logMan.infoWrite(logString: "No stored info found in KeyChain.")
            } catch KeychainError.unexpectedPasswordData {
                // Info found, but it was bad
                self.logMan.errorWrite(logString: "Information was found in KeyChain, but it was somehow corrupt.")
            } catch {
                // Something else
                self.logMan.fatalWrite(logString: "Unhandled exception found with extracting KeyChain info.")
            }
        }
    }
}
