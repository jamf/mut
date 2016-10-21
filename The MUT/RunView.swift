//
//  RunView.swift
//  The MUT
//
//  Created by Michael Levenick on 10/18/16.
//  Copyright © 2016 Levenick Enterprises LLC. All rights reserved.
//

// RUN PAGE

import Foundation
import Cocoa

class RunView: NSViewController {
    @IBOutlet weak var lblCredentials: NSTextField!
    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 600, height: 400)
    }
    override func viewDidLoad() {
        
    }
    
    
}
