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
    @IBOutlet weak var txtClientIdOutlet: NSTextField!
    @IBOutlet weak var txtClientSecretOutlet: NSSecureTextField!

    @IBOutlet weak var spinProgress: NSProgressIndicator!

    @IBOutlet weak var btnSubmitOutlet: NSButton!
    @IBOutlet weak var chkRememberMe: NSButton!
    
    @IBOutlet weak var chkAutoLoginOutlet: NSButton!
    @IBOutlet weak var lblAutoLogin: NSTextField!
    
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
            self.txtClientIdOutlet.stringValue = Credentials.clientId!
            self.txtClientSecretOutlet.stringValue = Credentials.clientSecret!
            if loginDefaults.bool(forKey: "AutoLogin") {
                self.logMan.writeLog(level: .info, logString: "Found credentials stored in KeyChain. Attempting login.")
                keyChainLogin = true
                self.btnSubmit(self)
            }
        } catch KeychainError.noPassword {
            // No info found in keychain
            self.logMan.writeLog(level: .info, logString: "No stored info found in KeyChain.")
            disableAutoLogin()
        } catch KeychainError.unexpectedPasswordData {
            // Info found, but it was bad
            self.logMan.writeLog(level: .error, logString: "Information was found in KeyChain, but it was somehow corrupt.")
        } catch {
            // Something else
            self.logMan.writeLog(level: .fatal, logString: "Unhandled exception found with extracting KeyChain info.")
        }
        
        // Restore Remember Me checkbox settings if we have a default stored
        if loginDefaults.bool(forKey: "Remember") {
            chkRememberMe.state = NSControl.StateValue.on
        } else {
            chkRememberMe.state = NSControl.StateValue.off
            disableAutoLogin()
        }
        
        // Restore Auto Login checkbox settings if we have a default stored
        if loginDefaults.bool(forKey: "AutoLogin") {
            chkAutoLoginOutlet.state = NSControl.StateValue.on
        } else {
            chkAutoLoginOutlet.state = NSControl.StateValue.off
        }
        
        if loginDefaults.string(forKey: "InstanceURL") != nil {
            self.txtURLOutlet.stringValue = loginDefaults.string(forKey: "InstanceURL")!
        }
        
        if loginDefaults.string(forKey: "ClientId") != nil {
            self.txtClientIdOutlet.stringValue = loginDefaults.string(forKey: "ClientId")!
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
        txtClientIdOutlet.stringValue = txtClientIdOutlet.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)

        // Warn the user if they have failed to enter an instancename AND prem URL
        if txtURLOutlet.stringValue == "" {
            _ = popPrompt().noServer()
        }

        // Warn the user if they have failed to enter a client ID
        if txtClientIdOutlet.stringValue == "" {
            _ = popPrompt().noClientId()
        }

        // Warn the user if they have failed to enter a client secret
        if txtClientSecretOutlet.stringValue == "" {
            _ = popPrompt().noClientSecret()
        }
        
        // Store the credentials information for later use
        Credentials.clientId = txtClientIdOutlet.stringValue
        Credentials.clientSecret = txtClientSecretOutlet.stringValue
        Credentials.server = txtURLOutlet.stringValue

        // Move forward with verification
        if txtURLOutlet.stringValue != ""
            && txtClientSecretOutlet.stringValue != ""
            && txtClientIdOutlet.stringValue != "" {
            
            // Change the UI to a running state
            guiRunning()

            DispatchQueue.global(qos: .background).async {
                // Get our token data from the API class
                self.tokenMan.getToken(allowUntrusted: self.loginDefaults.bool(forKey: "Insecure"))
                DispatchQueue.main.async {
                    //print(String(decoding: Token.data!, as: UTF8.self)) // Uncomment for debugging
                    // Reset the GUI and pop up a warning with the info if we get a fatal error
                    if String(decoding: Token.data!, as: UTF8.self).contains("FATAL") {
                        _ = popPrompt().fatalWarning(error: String(decoding: Token.data!, as: UTF8.self))
                        self.guiReset()
                    } else {
                        // No error found leads you here:
                        if String(decoding: Token.data!, as: UTF8.self).contains("access_token") {
                            // Good credentials here, as told by there being an access_token
                            do {
                                // Parse the JSON to return token and Expiry
                                let newJson = try JSON(data: Token.data!)
                                Token.value = newJson["access_token"].stringValue
                                
                                // OAuth returns expires_in as seconds from now
                                let expiresIn = newJson["expires_in"].intValue
                                let currentTime = Int(Date().timeIntervalSince1970 * 1000)
                                Token.expiration = currentTime + (expiresIn * 1000)
                                
                                self.dismiss(self)
                            } catch let error as NSError {
                                self.logMan.writeLog(level: .error, logString: "Failed to load: \(error.localizedDescription)")
                            }
                            
                            // Store the client ID if we should
                            if self.loginDefaults.bool(forKey: "StoreClientId"){
                                self.loginDefaults.set(self.txtClientIdOutlet.stringValue, forKey: "ClientId")
                                self.loginDefaults.synchronize()
                            } else {
                                self.loginDefaults.removeObject(forKey: "ClientId")
                            }
                            
                            // Store the URL if we should
                            if self.loginDefaults.bool(forKey: "StoreURL"){
                                self.loginDefaults.set(self.txtURLOutlet.stringValue, forKey: "InstanceURL")
                                self.loginDefaults.synchronize()
                            } else {
                                self.loginDefaults.removeObject(forKey: "InstanceURL")
                            }

                            // Store credentials if button pressed
                            if self.loginDefaults.bool(forKey: "Remember") {
                                
                                // Attempt to save the information in keychain
                                self.logMan.writeLog(level: .info, logString: "Remember Me checkbox checked. Storing credentials in KeyChain for later use.")
                                DispatchQueue.global(qos: .background).async {
                                    do {
                                        try KeyChainHelper.save(clientId: Credentials.clientId!,
                                                                clientSecret: Credentials.clientSecret!,
                                                                server: Credentials.server!)
                                    } catch {
                                        self.logMan.writeLog(level: .error, logString: "Error writing credentials to keychain. \(error)")
                                    }
                                }

                            } else {
                                self.loginDefaults.removeObject(forKey: "Remember")
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
    
    @IBAction func chkRememberAction(_ sender: Any) {
        if chkRememberMe.state == NSControl.StateValue.on {
            loginDefaults.set(true, forKey: "Remember")
            enableAutoLogin()
        } else {
            // Remove both auto login and rememberme from defaults
            loginDefaults.removeObject(forKey: "AutoLogin")
            loginDefaults.removeObject(forKey: "Remember")
            
            disableAutoLogin()
            
            // Clear the keychain, just in case.
            deleteKeyChain()
        }
    }
    
    @IBAction func chkAutoLoginAction(_ sender: Any) {
        if chkAutoLoginOutlet.state == NSControl.StateValue.on {
            loginDefaults.set(true, forKey: "AutoLogin")
        } else {
            loginDefaults.removeObject(forKey: "AutoLogin")
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
                self.logMan.writeLog(level: .info, logString: "Deleting information stored in keychain.")
            } catch KeychainError.noPassword {
                // No info found in keychain
                self.logMan.writeLog(level: .info, logString: "No stored info found in KeyChain.")
            } catch KeychainError.unexpectedPasswordData {
                // Info found, but it was bad
                self.logMan.writeLog(level: .error, logString: "Information was found in KeyChain, but it was somehow corrupt.")
            } catch {
                // Something else
                self.logMan.writeLog(level: .fatal, logString: "Unhandled exception found with extracting KeyChain info.")
            }
        }
    }
    
    func disableAutoLogin(){
        // Disable option to auto login if rememberme unchecked
        loginDefaults.removeObject(forKey: "AutoLogin")
        chkAutoLoginOutlet.state = NSControl.StateValue.off
        chkAutoLoginOutlet.isEnabled = false
        lblAutoLogin.textColor = .secondaryLabelColor
    }
    
    func enableAutoLogin(){
        // Re-enable option to auto login if rememberme checked
        chkAutoLoginOutlet.isEnabled = true
        lblAutoLogin.textColor = .labelColor
    }
}
