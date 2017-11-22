//
//  ViewController.swift
//  The MUT
//
//  Created by Michael Levenick on 10/17/16.
//  Copyright © 2016 Levenick Enterprises LLC. All rights reserved.
//


import Cocoa
import Foundation

class loginWindow: NSViewController, URLSessionDelegate {

    let loginDefaults = UserDefaults.standard
    
    @IBOutlet weak var txtCloudOutlet: NSTextField!
    @IBOutlet weak var txtPremOutlet: NSTextField!
    @IBOutlet weak var txtUserOutlet: NSTextField!
    @IBOutlet weak var txtPassOutlet: NSSecureTextField!
    @IBOutlet weak var btnStoreUserOutlet: NSButton!
    @IBOutlet weak var btnStoreURLOutlet: NSButton!
    
    var doNotRun: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Restoring Username if not null
        if loginDefaults.value(forKey: "UserName") != nil {
            txtUserOutlet.stringValue = loginDefaults.value(forKey: "UserName") as! String
            btnStoreUserOutlet.state = 1
        }
        
        // Restore Instance Name if Hosted
        if loginDefaults.value(forKey: "HostedInstanceName") != nil {
            txtCloudOutlet.stringValue = loginDefaults.value(forKey: "HostedInstanceName") as! String
        }
        
        // Restore Prem URL if on prem
        if loginDefaults.value(forKey: "PremInstanceURL") != nil {
            txtPremOutlet.stringValue = loginDefaults.value(forKey: "PremInstanceURL") as! String
        }
        
    }
    
    @IBAction func txtPrem(_ sender: Any) {
    }
    @IBAction func txtCloud(_ sender: Any) {
    }
    
    @IBAction func btnSubmit(_ sender: Any) {
        //self.dismiss(self)
        
        if txtPremOutlet.stringValue == "" && txtCloudOutlet.stringValue == "" {
            _ = popPrompt().generalWarning(question: "No Server Info", text: "It appears that you have not entered any information for your Jamf Pro URL. Please enter either a Jamf Cloud instance name, or your full URL if you host your own server.")
            doNotRun = "1" // Set Do Not Run flag
        }
        
        if txtPremOutlet.stringValue != "" && txtCloudOutlet.stringValue != "" {
            _ = popPrompt().generalWarning(question: "Too Much Server Info", text: "It appears that you have entered both a Jamf Cloud instance name as well as an on-premise URL. Please remove either the Jamf Cloud instance name if you host your own server, or remove the 'On Prem URL' if you are Jamf Cloud hosted.")
            doNotRun = "1" // Set Do Not Run flag
        }
        
        if txtUserOutlet.stringValue == "" {
            _ = popPrompt().generalWarning(question: "No Username Found", text: "It appears that you have not entered a username for MUT to use while accessing Jamf Pro. Please enter your username and password, and try again.")
            doNotRun = "1" // Set Do Not Run flag
        }
        
        if txtPassOutlet.stringValue == "" {
            _ = popPrompt().generalWarning(question: "No Password Found", text: "It appears that you have not entered a password for MUT to use while accessing Jamf Pro. Please enter your username and password, and try again.")
            doNotRun = "1" // Set Do Not Run flag
        }
        
        if doNotRun != "1" {
             _ = popPrompt().generalWarning(question: "Good", text: "All cirteria met.")
        } else {
            // Reset the Do Not Run flag so that on subsequent runs we try the checks again.
            doNotRun = "0"
        }
    }
    
    // MARK: - Verify Credentials
    /*@IBAction func btnAcceptCredentials(_ sender: AnyObject) {
        
        if radioHosted.state == 1 {
            if txtHosted.stringValue != "" {
                
                // Add JSS Resource and jamfcloud info
                serverURL = "https://\(txtHosted.stringValue).jamfcloud.com/JSSResource/"
                
                // Save the hosted instance and wipe saved prem server
                let instanceName = txtHosted.stringValue
                mainViewDefaults.set(instanceName, forKey: "HostedInstanceName")
                mainViewDefaults.set(serverURL!, forKey: "ServerURL")
                mainViewDefaults.removeObject(forKey: "PremInstanceURL")
                
                mainViewDefaults.synchronize()
                let cleanURL = serverURL!.replacingOccurrences(of: "JSSResource/", with: "")
                appendLogString(stringToAppend: "URL: \(cleanURL)")
                printLineBreak()
                
            } else {
                // If no URL is filled, warn user
                _ = popPrompt().generalWarning(question: "No Server Info", text: "You have selected the option for a hosted Jamf server, but no instance name was entered. Please enter your instance name and try again.")
            }
        }
        
        // If Prem Radio Chekced
        if radioPrem.state == 1 {
            
            // Check if URL is filled
            if txtPrem.stringValue != "" {
                
                // Add JSS Resource and remove double slashes
                serverURL = "\(txtPrem.stringValue)/JSSResource/"
                serverURL = serverURL.replacingOccurrences(of: "//JSSResource", with: "/JSSResource")
                
                // Save the prem URL and wipe saved hosted names
                let serverSave = txtPrem.stringValue
                mainViewDefaults.set(serverSave, forKey: "PremInstanceURL")
                mainViewDefaults.set(serverURL!, forKey: "ServerURL")
                mainViewDefaults.removeObject(forKey: "HostedInstanceName")
                mainViewDefaults.synchronize()
                let cleanURL = serverURL!.replacingOccurrences(of: "JSSResource/", with: "")
                appendLogString(stringToAppend: "URL: \(cleanURL)")
                
            } else {
                // If no URL is filled, warn user
                _ = popPrompt().generalWarning(question: "No Server Info", text: "You have selected the option for an on prem server, but no server URL was entered. Please enter your instance name and try again.")
            }
        }
        
        if serverURL != nil {
            btnAcceptOutlet.isHidden = true
            spinWheel.startAnimation(self)
            let concatCredentials = "\(txtUser.stringValue):\(txtPass.stringValue)"
            let utf8Credentials = concatCredentials.data(using: String.Encoding.utf8)
            base64Credentials = utf8Credentials?.base64EncodedString()
            
            if txtUser.stringValue != "" && txtPass.stringValue != "" {
                
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
                                self.globalServerCredentials = self.base64Credentials
                                self.globalServerURL = self.serverURL
                                self.appendLogString(stringToAppend: "Credentials Successfully Verified.")
                                self.printLineBreak()
                                self.verified = true
                                
                                // Store username if button pressed
                                if self.btnStoreUser.state == 1 {
                                    self.mainViewDefaults.set(self.txtUser.stringValue, forKey: "UserName")
                                    self.mainViewDefaults.synchronize()
                                    
                                } else {
                                    self.mainViewDefaults.removeObject(forKey: "UserName")
                                    self.mainViewDefaults.synchronize()
                                }
                                self.spinWheel.stopAnimation(self)
                                self.btnAcceptOutlet.isHidden = false
                                
                            } else {
                                DispatchQueue.main.async {
                                    self.spinWheel.stopAnimation(self)
                                    self.btnAcceptOutlet.isHidden = false
                                    _ = popPrompt().generalWarning(question: "Invalid Credentials", text: "The credentials you entered do not seem to have sufficient permissions. This could be due to an incorrect user/password, or possibly from insufficient permissions. MUT tests this against the user's ability to view the Activation Code via the API.")
                                    if self.chkBypass.state == 1 {
                                        print("BYPASSED")
                                        self.globalServerCredentials = self.base64Credentials
                                        self.globalServerURL = self.serverURL
                                        self.appendLogString(stringToAppend: "Credential Verification Bypassed - USE WITH CAUTION.")
                                        self.printLineBreak()
                                        self.verified = true
                                    }
                                    
                                }
                            }
                        }
                        if error != nil {
                            _ = popPrompt().generalWarning(question: "Fatal Error", text: "The MUT received a fatal error at authentication. The most common cause of this is an incorrect server URL. The full error output is below. \n\n \(error!.localizedDescription)")
                            self.spinWheel.stopAnimation(self)
                            self.btnAcceptOutlet.isHidden = false
                        }
                    })
                    task.resume()
                }
            } else {
                _ = popPrompt().generalWarning(question: "Missing Credentials", text: "Either the username or the password field was left blank. Please fill in both the username and password field to verify credentials.")
                self.spinWheel.stopAnimation(self)
                self.btnAcceptOutlet.isHidden = false
            }
        }
    }*/
    
    
    
    
}

