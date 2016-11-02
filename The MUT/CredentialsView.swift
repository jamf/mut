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
import Alamofire

// Protocol to pass back credentials
protocol DataSentCredentials {
    func userDidEnterCredentials(serverCredentials: String)
}

protocol DataSentUsername {
    func userDidSaveUsername(savedUser: String)
}


class CredentialsView: NSViewController {
    
    var base64Credentials: String!
    var globalServerCredentials: String!
    let credentialsViewDefaults = UserDefaults.standard
    var responseResult: String!
    
    func dialogueWarning (question: String, text: String) -> Bool {
        
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlertStyle.warning
        myPopup.addButton(withTitle: "OK")
        return myPopup.runModal() == NSAlertFirstButtonReturn
    }
    
    // Declare variable to use for delegate
    var delegateCredentials: DataSentCredentials? = nil
    var delegateUsername: DataSentUsername? = nil
    
    // Declare global var for URL passed in
    var ApprovedURL: String!
    
    // Define Outlets for User and Password
    @IBOutlet weak var txtUser: NSTextField!
    @IBOutlet weak var txtPass: NSSecureTextField!
    @IBOutlet weak var btnStoreUser: NSButton!
    
    override func viewWillAppear() {
        
        //resize the view
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 600, height: 203)
        ApprovedURL = self.representedObject as! String
    }
    
    override func viewDidLoad() {
        
        // Restore Username after view loads
        if credentialsViewDefaults.value(forKey: "UserName") != nil {
            txtUser.stringValue = credentialsViewDefaults.value(forKey: "UserName") as! String
            btnStoreUser.state = 1
        }
        
    }
    
/*
     @IBAction func btnVerifyCredentials(_ sender: AnyObject) {
        let concatCredentials = "\(txtUser.stringValue):\(txtPass.stringValue)"
        let utf8Credentials = concatCredentials.data(using: String.Encoding.utf8)
        let base64Credentials = utf8Credentials?.base64EncodedString()
        print (base64Credentials)
        globalServerCredentials = base64Credentials!
    }

    
    @IBAction func btnTest(_ sender: Any) {
        
        let headers: HTTPHeaders = [
            "Authorization": "Basic \(base64Credentials!)",
            "Accept": "application/json"
        ]
        
        Alamofire.request("\(ApprovedURL!)activationcode", headers: headers).responseJSON { response in
            //debugPrint(response)
            print(response.result)
        }
        
    }
 */
    
    
    @IBAction func btnCancel(_ sender: AnyObject) {
        delegateCredentials?.userDidEnterCredentials(serverCredentials: "CREDENTIAL AUTHENTICATION FAILURE")
        self .dismissViewController(self)
    }
    
    // Accept Credentials Button
    @IBAction func btnDismissCredentials(_ sender: AnyObject) {
        
        
        
        if delegateCredentials != nil {
            
            let concatCredentials = "\(txtUser.stringValue):\(txtPass.stringValue)"
            let utf8Credentials = concatCredentials.data(using: String.Encoding.utf8)
            base64Credentials = utf8Credentials?.base64EncodedString()
            print (base64Credentials)
            globalServerCredentials = base64Credentials!
            
            if txtUser.stringValue != "" && txtPass.stringValue != "" {
                
                if globalServerCredentials != nil {
                    
                    //UNCOMMENT IF THIS DOESN"T WORK
                    /* delegateCredentials?.userDidEnterCredentials(serverCredentials: globalServerCredentials) // Delegate for passing to main view
                    
                    // Store username if button pressed
                    if btnStoreUser.state == 1 {
                        credentialsViewDefaults.set(txtUser.stringValue, forKey: "UserName")
                        credentialsViewDefaults.synchronize()
                        delegateUsername?.userDidSaveUsername(savedUser: txtUser.stringValue)
                    } else {
                        credentialsViewDefaults.removeObject(forKey: "UserName")
                        credentialsViewDefaults.synchronize()
                    }*/
                    
                    // Test the credentials
                    let headers: HTTPHeaders = [
                        "Authorization": "Basic \(base64Credentials!)",
                        "Accept": "application/json"
                    ]
                    
                    Alamofire.request("\(ApprovedURL!)activationcode", headers: headers).responseJSON { response in
                        //debugPrint(response)
                        print(response.result)
                        //let results = response.result as! String
                        //self.responseResult = results
                        if response.result.isSuccess {
                            // _ = self.dialogueWarning(question: "It's good!", text: "Your permissions are working perfectly.")
                            self.delegateCredentials?.userDidEnterCredentials(serverCredentials: self.globalServerCredentials) // Delegate for passing to main view
                            
                            // Store username if button pressed
                            if self.btnStoreUser.state == 1 {
                                self.credentialsViewDefaults.set(self.txtUser.stringValue, forKey: "UserName")
                                self.credentialsViewDefaults.synchronize()
                                self.delegateUsername?.userDidSaveUsername(savedUser: self.txtUser.stringValue)
                            } else {
                                self.credentialsViewDefaults.removeObject(forKey: "UserName")
                                self.credentialsViewDefaults.synchronize()
                            }

                            self.dismissViewController(self)
                        }
                        if response.result.isFailure {
                            _ = self.dialogueWarning(question: "Invalid Credentials", text: "The credentials you entered do not seem to have sufficient permissions. This could be due to an incorrect user/password, or possibly from insufficient permissions. MUT tests this against the user's ability to view the Activation Code via the API.")
                        }
                    }
                    
                    
                }
                
            } else {
                _ = dialogueWarning(question: "Missing Credentials", text: "Either the username or the password field was left blank. Please fill in both the username and password field to verify credentials.")
            }
        }
    }
}
