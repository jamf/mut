//
//  loginWindow.swift
//  The MUT
//
//  Created by Michael Levenick on 5/28/19.
//  Copyright © 2019 Levenick Enterprises LLC. All rights reserved.
//

import Cocoa
import Foundation

// Delegate required to send data forward to the main view controller
protocol DataSentDelegate {
    func userDidAuthenticate(base64Credentials: String, url: String, token: String, expiry: Int)
}

class loginWindow: NSViewController, URLSessionDelegate {

    let loginDefaults = UserDefaults.standard
    var delegateAuth: DataSentDelegate? = nil


    @IBOutlet weak var txtURLOutlet: NSTextField!
    @IBOutlet weak var txtUserOutlet: NSTextField!
    @IBOutlet weak var txtPassOutlet: NSSecureTextField!
    @IBOutlet weak var spinProgress: NSProgressIndicator!
    @IBOutlet weak var btnSubmitOutlet: NSButton!
    @IBOutlet weak var chkRememberMe: NSButton!
    @IBOutlet weak var chkBypass: NSButton!

    var doNotRun: Bool!
    var serverURL: String!
    var base64Credentials: String!
    var token: String!
    var verified = false

    let punctuation = CharacterSet(charactersIn: ".:/")

    let APIFunc = API()

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
        
        // Move the cursor to the password field if that's where it should be
        if ( loginDefaults.value(forKey: "InstanceURL") != nil || loginDefaults.value(forKey: "InstanceURL") != nil ) && loginDefaults.value(forKey: "UserName") != nil {
            if self.txtPassOutlet.acceptsFirstResponder == true {
                self.txtPassOutlet.becomeFirstResponder()
            }
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
        txtPassOutlet.stringValue = txtPassOutlet.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)

        // Warn the user if they have failed to enter an instancename AND prem URL
        if txtURLOutlet.stringValue == "" {
            _ = popPrompt().generalWarning(question: "No Server Info", text: "It appears that you have not entered any information for your Jamf Pro URL. Please enter either a Jamf Cloud instance name, or your full URL if you host your own server.")
            doNotRun = true // Set Do Not Run flag
        }

        // Warn the user if they have failed to enter a username
        if txtUserOutlet.stringValue == "" {
            _ = popPrompt().generalWarning(question: "No Username Found", text: "It appears that you have not entered a username for MUT to use while accessing Jamf Pro. Please enter your username and password, and try again.")
            doNotRun = true // Set Do Not Run flag
        }

        // Warn the user if they have failed to enter a password
        if txtPassOutlet.stringValue == "" {
            _ = popPrompt().generalWarning(question: "No Password Found", text: "It appears that you have not entered a password for MUT to use while accessing Jamf Pro. Please enter your username and password, and try again.")
            doNotRun = true // Set Do Not Run flag
        }

        // Move forward with verification if we have not flagged the doNotRun flag
        if !doNotRun {
            
            // Change the UI to a running state
            btnSubmitOutlet.isHidden = true
            spinProgress.startAnimation(self)
            
            let tokenData = APIFunc.verifyCredentials(url: txtURLOutlet.stringValue, user: txtUserOutlet.stringValue, password: txtPassOutlet.stringValue)
            //print(String(decoding: tokenData, as: UTF8.self)) // Uncomment for debugging
            if String(decoding: tokenData, as: UTF8.self).contains("FATAL") {
                _ = popPrompt().generalWarning(question: "Fatal Error", text: "The MUT received a fatal error at authentication. The most common cause of this is an incorrect server URL. The full error output is below. \n\n \(String(decoding: tokenData, as: UTF8.self))")
                self.spinProgress.stopAnimation(self)
                self.btnSubmitOutlet.isHidden = false
            } else {
                
                if String(decoding: tokenData, as: UTF8.self).contains("token") {
                    // Good credentials here, as told by there being a token
                    self.verified = true
                    do {
                        // Parse the JSON resturned to get the token and expiry
                        let tokenJson = try JSONSerialization.jsonObject(with: tokenData, options: []) as! [String: AnyObject]
                        let token = tokenJson["token"] as? String
                        let expiry = tokenJson["expires"] as? Int
                        // print(token!) // Uncomment for debugging
                        // print(expiry!) // Uncomment for debugging
                        
                        // Get current epoch time in ms
                        let currentEpoch = Int(Date().timeIntervalSince1970 * 1000)
                        // print(currentEpoch) // Uncomment for debugging
                        // Find the difference between expiry time and current epoch
                        let timeToExpire = expiry! - currentEpoch
                        print("Expires in \(timeToExpire/1000) seconds")
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
                        self.dismiss(self)
                        // Delegate stuff to pass info forward goes here
                    }
                } else {
                    // Bad credentials here
                    DispatchQueue.main.async {
                        self.spinProgress.stopAnimation(self)
                        self.btnSubmitOutlet.isHidden = false
                        _ = popPrompt().generalWarning(question: "Invalid Credentials", text: "The credentials you entered do not seem to have sufficient permissions. This could be due to an incorrect user/password, or possibly from insufficient permissions.\n\nMUT tests this against the user's ability to generate a token for the new JPAPI/UAPI. This token is now required for some tasks that MUT performs.")
                        if self.chkBypass.state.rawValue == 1 {
                            if self.delegateAuth != nil {
                                // Delegate stuff to pass info forward goes here
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

    // This is required to allow un-trusted SSL certificates. Leave it alone.
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    @IBAction func btnQuit(_ sender: Any) {
        self.dismiss(self)
        NSApplication.shared.terminate(self)
    }
}
