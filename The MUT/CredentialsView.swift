//
//  CredentialsView.swift
//  The MUT
//
//  Created by Michael Levenick on 10/18/16.
//  Copyright © 2016 Levenick Enterprises LLC. All rights reserved.
//

// CREDENTIALS PAGE


import Foundation
import Cocoa


// Protocol to pass back credentials
protocol DataSentCredentials {
    func userDidEnterCredentials(serverCredentials: String)
}

protocol DataSentUsername {
    func userDidSaveUsername(savedUser: String)
}

class CredentialsView: NSViewController, URLSessionDelegate {
    
    var base64Credentials: String!
    let credentialsViewDefaults = UserDefaults.standard
    var responseResult: String!
    var allowUntrustedURL: String!
    
    // Declare variable to use for delegate
    var delegateCredentials: DataSentCredentials? = nil
    var delegateUsername: DataSentUsername? = nil
    
    // Declare global var for URL passed in
    var ApprovedURL: String!
    
    
    // Define Outlets for User and Password
    @IBOutlet weak var txtUser: NSTextField!
    @IBOutlet weak var txtPass: NSSecureTextField!
    @IBOutlet weak var btnStoreUser: NSButton!
    @IBOutlet weak var btnAcceptOutlet: NSButton!
    @IBOutlet weak var spinWheel: NSProgressIndicator!
    
    override func viewWillAppear() {
        
        //resize the view
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 600, height: 203)
        ApprovedURL = self.representedObject as! String
        allowUntrustedURL = ApprovedURL.replacingOccurrences(of: "https://", with: "")
        allowUntrustedURL = allowUntrustedURL.replacingOccurrences(of: ":8443/JSSResource/", with: "")

        btnAcceptOutlet.isHidden = false
        }
    
    override func viewDidLoad() {
        
        // Restore Username after view loads
        if credentialsViewDefaults.value(forKey: "UserName") != nil {
            txtUser.stringValue = credentialsViewDefaults.value(forKey: "UserName") as! String
            btnStoreUser.state = 1
            //txtPass.stringValue = " "
            txtUser.refusesFirstResponder = true
            txtPass.becomeFirstResponder()
            
        }
    }

    @IBAction func btnCancel(_ sender: AnyObject) {
        
        delegateCredentials?.userDidEnterCredentials(serverCredentials: "CREDENTIAL AUTHENTICATION FAILURE")
        self .dismissViewController(self)
    }
    
    // Accept Credentials Button
    @IBAction func btnAcceptCredentials(_ sender: AnyObject) {

        if delegateCredentials != nil {
            
            btnAcceptOutlet.isHidden = true
            spinWheel.startAnimation(self)
            let concatCredentials = "\(txtUser.stringValue):\(txtPass.stringValue)"
            let utf8Credentials = concatCredentials.data(using: String.Encoding.utf8)
            base64Credentials = utf8Credentials?.base64EncodedString()
            
            if txtUser.stringValue != "" && txtPass.stringValue != "" {
                
                DispatchQueue.main.async {
                    let myURL = "\(self.ApprovedURL!)activationcode"
                    let encodedURL = NSURL(string: myURL)
                    let request = NSMutableURLRequest(url: encodedURL as! URL)
                    request.httpMethod = "GET"
                    let configuration = URLSessionConfiguration.default
                    configuration.httpAdditionalHeaders = ["Authorization" : "Basic \(self.base64Credentials!)", "Content-Type" : "text/xml", "Accept" : "text/xml"]
                    let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
                    let task = session.dataTask(with: request as URLRequest, completionHandler: {
                        (data, response, error) -> Void in
                        if let httpResponse = response as? HTTPURLResponse {
                            //print(httpResponse.statusCode)
                            
                            if httpResponse.statusCode >= 199 && httpResponse.statusCode <= 299 {
                                self.delegateCredentials?.userDidEnterCredentials(serverCredentials: self.base64Credentials) // Delegate for passing to main view
                                
                                // Store username if button pressed
                                if self.btnStoreUser.state == 1 {
                                    self.credentialsViewDefaults.set(self.txtUser.stringValue, forKey: "UserName")
                                    self.credentialsViewDefaults.synchronize()
                                    self.delegateUsername?.userDidSaveUsername(savedUser: self.txtUser.stringValue)
                                } else {
                                    self.credentialsViewDefaults.removeObject(forKey: "UserName")
                                    self.credentialsViewDefaults.synchronize()
                                }
                                self.spinWheel.stopAnimation(self)
                                self.dismissViewController(self)
                            } else {
                                DispatchQueue.main.async {
                                    self.spinWheel.stopAnimation(self)
                                    self.btnAcceptOutlet.isHidden = false
                                    _ = self.dialogueWarning(question: "Invalid Credentials", text: "The credentials you entered do not seem to have sufficient permissions. This could be due to an incorrect user/password, or possibly from insufficient permissions. MUT tests this against the user's ability to view the Activation Code via the API.")
                                }
                            }
                        }
                        if error != nil {
                            _ = self.dialogueWarning(question: "Fatal Error", text: "The MUT received a fatal error at authentication. The most common cause of this is an incorrect server URL. The full error output is below. \n\n \(error!.localizedDescription)")
                        }
                    })
                    task.resume()
                }
            } else {
                _ = dialogueWarning(question: "Missing Credentials", text: "Either the username or the password field was left blank. Please fill in both the username and password field to verify credentials.")
                self.spinWheel.stopAnimation(self)
                self.btnAcceptOutlet.isHidden = false
            }
        }
    }
    
    func dialogueWarning (question: String, text: String) -> Bool {
        
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlertStyle.warning
        myPopup.addButton(withTitle: "OK")
        return myPopup.runModal() == NSAlertFirstButtonReturn
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        
    }
}
