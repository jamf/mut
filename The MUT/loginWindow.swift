//
//  ViewController.swift
//  The MUT
//
//  Created by Michael Levenick on 10/17/16.
//  Copyright © 2016 Levenick Enterprises LLC. All rights reserved.
//


import Cocoa
import Foundation

protocol DataSentDelegate {
    func userDidAuthenticate(base64Credentials: String, url: String)
}

class loginWindow: NSViewController, URLSessionDelegate {

    let loginDefaults = UserDefaults.standard
    var delegateAuth: DataSentDelegate? = nil
    
    @IBOutlet weak var txtCloudOutlet: NSTextField!
    @IBOutlet weak var txtPremOutlet: NSTextField!
    @IBOutlet weak var txtUserOutlet: NSTextField!
    @IBOutlet weak var txtPassOutlet: NSSecureTextField!
    @IBOutlet weak var spinProgress: NSProgressIndicator!
    @IBOutlet weak var btnSubmitOutlet: NSButton!
    @IBOutlet weak var boxAdvanced: NSBox!
    @IBOutlet weak var chkStoreUser: NSButton!
    @IBOutlet weak var chkStoreURL: NSButton!
    @IBOutlet weak var chkBypass: NSButton!
    @IBOutlet weak var btnAdvancedOutlet: NSButton!
    
    var doNotRun: String!
    var serverURL: String!
    var base64Credentials: String!
    var verified = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Restore the Username to text box if we have a default stored
        if loginDefaults.value(forKey: "UserName") != nil {
            txtUserOutlet.stringValue = loginDefaults.value(forKey: "UserName") as! String
            chkStoreUser.state = 1
        }
        
        // Restore the Instance Name to text box if we have a default stored
        if loginDefaults.value(forKey: "HostedInstanceName") != nil {
            txtCloudOutlet.stringValue = loginDefaults.value(forKey: "HostedInstanceName") as! String
        }
        
        // Restore Prem URL to text box if we have a default stored
        if loginDefaults.value(forKey: "PremInstanceURL") != nil {
            txtPremOutlet.stringValue = loginDefaults.value(forKey: "PremInstanceURL") as! String
        }
        
        if ( loginDefaults.value(forKey: "PremInstanceURL") != nil || loginDefaults.value(forKey: "PremInstanceURL") != nil ) && loginDefaults.value(forKey: "UserName") != nil {
            if self.txtPassOutlet.acceptsFirstResponder == true {
                self.txtPassOutlet.becomeFirstResponder()
            }
            
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        // If we have a URL and a User stored focus the password field
        if ( loginDefaults.value(forKey: "HostedInstanceName") != nil || loginDefaults.value(forKey: "PremInstanceURL") != nil ) && loginDefaults.value(forKey: "UserName") != nil {
                self.txtPassOutlet.becomeFirstResponder()
        }
    }
    
    @IBAction func txtPrem(_ sender: Any) {
    }
    @IBAction func txtCloud(_ sender: Any) {
    }
    
    @IBAction func btnSubmit(_ sender: Any) {
        //self.dismiss(self)
        txtPremOutlet.stringValue = txtPremOutlet.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)
        txtCloudOutlet.stringValue = txtCloudOutlet.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)
        txtUserOutlet.stringValue = txtUserOutlet.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)
        txtPassOutlet.stringValue = txtPassOutlet.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)
        
        // Warn the user if they have failed to enter an instancename AND prem URL
        if txtPremOutlet.stringValue == "" && txtCloudOutlet.stringValue == "" {
            _ = popPrompt().generalWarning(question: "No Server Info", text: "It appears that you have not entered any information for your Jamf Pro URL. Please enter either a Jamf Cloud instance name, or your full URL if you host your own server.")
            doNotRun = "1" // Set Do Not Run flag
        }
        
        // Warn the user if they have entered both an instancename AND prem URL
        if txtPremOutlet.stringValue != "" && txtCloudOutlet.stringValue != "" {
            _ = popPrompt().generalWarning(question: "Too Much Server Info", text: "It appears that you have entered both a Jamf Cloud instance name as well as an on-premise URL. Please remove either the Jamf Cloud instance name if you host your own server, or remove the 'On Prem URL' if you are Jamf Cloud hosted.")
            doNotRun = "1" // Set Do Not Run flag
        }
        
        // Warn the user if they have failed to enter a username
        if txtUserOutlet.stringValue == "" {
            _ = popPrompt().generalWarning(question: "No Username Found", text: "It appears that you have not entered a username for MUT to use while accessing Jamf Pro. Please enter your username and password, and try again.")
            doNotRun = "1" // Set Do Not Run flag
        }
        
        // Warn the user if they have failed to enter a password
        if txtPassOutlet.stringValue == "" {
            _ = popPrompt().generalWarning(question: "No Password Found", text: "It appears that you have not entered a password for MUT to use while accessing Jamf Pro. Please enter your username and password, and try again.")
            doNotRun = "1" // Set Do Not Run flag
        }
        
        // Move forward with verification if we have not flagged the doNotRun flag
        if doNotRun != "1" {
            
            // Create the API-Friendly Jamf Pro URL with resource appended
            if txtCloudOutlet.stringValue != "" {
                serverURL = "https://\(txtCloudOutlet.stringValue).jamfcloud.com/JSSResource/"
                if chkStoreURL.state == 1 {
                    // Store Defaults if the button is selected to store defaults
                    let instanceName = txtCloudOutlet.stringValue
                    loginDefaults.set(instanceName, forKey: "HostedInstanceName")
                    loginDefaults.set(serverURL!, forKey: "ServerURL")
                    loginDefaults.removeObject(forKey: "PremInstanceURL")
                } else {
                    // Clear the defaults if we have un-checked the store url button
                    loginDefaults.removeObject(forKey: "HostedInstanceName")
                    loginDefaults.removeObject(forKey: "ServerURL")
                    loginDefaults.removeObject(forKey: "PremInstanceURL")
                }
            }
            
            if txtPremOutlet.stringValue != "" {
                serverURL = "\(txtPremOutlet.stringValue)/JSSResource/"
                serverURL = serverURL.replacingOccurrences(of: "//JSSResource", with: "/JSSResource") // Clean up in case of double slash
                if chkStoreURL.state == 1 {
                    // Store Defaults if the button is selected to store defaults
                    let serverSave = txtPremOutlet.stringValue
                    loginDefaults.set(serverSave, forKey: "PremInstanceURL")
                    loginDefaults.set(serverURL!, forKey: "ServerURL")
                    loginDefaults.removeObject(forKey: "HostedInstanceName")
                } else {
                    // Clear the defaults if we have un-checked the store url button
                    loginDefaults.removeObject(forKey: "HostedInstanceName")
                    loginDefaults.removeObject(forKey: "ServerURL")
                    loginDefaults.removeObject(forKey: "PremInstanceURL")
                }
            }
            
            btnSubmitOutlet.isHidden = true
            spinProgress.startAnimation(self)
            
            // Concatenate the credentials and base64 encode the resulting string
            let concatCredentials = "\(txtUserOutlet.stringValue):\(txtPassOutlet.stringValue)"
            let utf8Credentials = concatCredentials.data(using: String.Encoding.utf8)
            base64Credentials = utf8Credentials?.base64EncodedString()
            
            // MARK - Credential Verification API Call
            
            DispatchQueue.main.async {
                let myURL = xmlBuilder().createGETURL(url: self.serverURL!)
                let request = NSMutableURLRequest(url: myURL)
                request.httpMethod = "GET"
                let configuration = URLSessionConfiguration.default
                configuration.httpAdditionalHeaders = ["Authorization" : "Basic \(self.base64Credentials!)", "Content-Type" : "text/xml", "Accept" : "text/xml"]
                let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
                let task = session.dataTask(with: request as URLRequest, completionHandler: {
                    (data, response, error) -> Void in
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode >= 199 && httpResponse.statusCode <= 299 {
                            self.verified = true
                            print("Good to go")
                            // Store username if button pressed
                            if self.chkStoreUser.state == 1 {
                                self.loginDefaults.set(self.txtUserOutlet.stringValue, forKey: "UserName")
                                self.loginDefaults.synchronize()
                                
                            } else {
                                self.loginDefaults.removeObject(forKey: "UserName")
                                self.loginDefaults.synchronize()
                            }
                            self.spinProgress.stopAnimation(self)
                            self.btnSubmitOutlet.isHidden = false
                            
                            //if self.delegate != nil {
                            self.delegateAuth?.userDidAuthenticate(base64Credentials: self.base64Credentials!, url: self.serverURL!)
                                self.dismissViewController(self)
                            //}
                            
                            
                            //self.dismiss(self)
                            //print(httpResponse.statusCode)
                            //print(httpResponse.description)
                            
                        } else {
                            DispatchQueue.main.async {
                                self.spinProgress.stopAnimation(self)
                                self.btnSubmitOutlet.isHidden = false
                                _ = popPrompt().generalWarning(question: "Invalid Credentials", text: "The credentials you entered do not seem to have sufficient permissions. This could be due to an incorrect user/password, or possibly from insufficient permissions. MUT tests this against the user's ability to view the Activation Code via the API.")
                                /*if self.chkBypass.state == 1 {
                                 print("BYPASSED")
                                 self.globalServerCredentials = self.base64Credentials
                                 self.globalServerURL = self.serverURL
                                 self.appendLogString(stringToAppend: "Credential Verification Bypassed - USE WITH CAUTION.")
                                 self.printLineBreak()
                                 self.verified = true
                                 }*/
                                
                            }
                        }
                    }
                    if error != nil {
                        _ = popPrompt().generalWarning(question: "Fatal Error", text: "The MUT received a fatal error at authentication. The most common cause of this is an incorrect server URL. The full error output is below. \n\n \(error!.localizedDescription)")
                        self.spinProgress.stopAnimation(self)
                        self.btnSubmitOutlet.isHidden = false
                    }
                })
                task.resume()
            }
            
        } else {
            // Reset the Do Not Run flag so that on subsequent runs we try the checks again.
            doNotRun = "0"
        }
    }
    // This is required to allow un-trusted SSL certificates. Leave it alone.
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    @IBAction func btnAdvanced(_ sender: Any) {
        if boxAdvanced.isHidden == true {
            boxAdvanced.isHidden = false
        } else {
            boxAdvanced.isHidden = true
        }
    }
    
}

