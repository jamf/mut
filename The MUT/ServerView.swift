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
    @IBAction func radioServerType(_ sender: AnyObject) {
        
        
    }

    
    override func viewDidLoad() {
        
        
    }
    @IBAction func btnDismissServer(_ sender: AnyObject) {
        self.dismissViewController(self)
    }
    

    
}
