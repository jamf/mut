//
//  ServerView.swift
//  The MUT
//
//  Created by Michael Levenick on 10/18/16.
//  Copyright © 2016 Levenick Enterprises LLC. All rights reserved.
//

// SERVER PAGE

import Foundation
import Cocoa

class ServerView: NSViewController {
    
    
    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 600, height: 400)
    }
    
    @IBOutlet weak var radioHosted: NSButton!
    @IBOutlet weak var radioPrem: NSButton!
    @IBOutlet weak var txtHosted: NSTextField!
    @IBOutlet weak var txtPrem: NSTextField!
    @IBAction func radioServerType(_ sender: AnyObject) {
        if radioHosted.state == 1 {
            txtPrem.isEnabled = false
            txtHosted.isEnabled = true
            txtHosted.becomeFirstResponder()
        } else {
            txtHosted.isEnabled = false
            txtPrem.isEnabled = true
            txtPrem.becomeFirstResponder()
        }
        
    }
    
    
    override func viewDidLoad() {
        
    }
    @IBAction func btnDismissServer(_ sender: AnyObject) {
        
        self.dismissViewController(self)
    }
    

    
}
