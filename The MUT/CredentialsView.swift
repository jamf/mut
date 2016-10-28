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

class CredentialsView: NSViewController {
    
    // Define Outlets for User and Password
    @IBOutlet weak var txtUser: NSTextField!
    @IBOutlet weak var txtPass: NSSecureTextField!
    
    override func viewWillAppear() {
        
        //resize the view
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 600, height: 303)
    }
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func btnVerifyCredentials(_ sender: AnyObject) {
        let concatCredentials = "\(txtUser.stringValue):\(txtPass.stringValue)"
        let utf8Credentials = concatCredentials.data(using: String.Encoding.utf8)
        let base64Credentials = utf8Credentials?.base64EncodedString()
        print (base64Credentials)
        
    }
    
    
    @IBAction func btnDismissCredentials(_ sender: AnyObject) {
        
        
        self.dismissViewController(self)
    }
    
    
}
