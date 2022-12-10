//
//  InsecureSSLPopover.swift
//  MUT
//
//  Created by Michael Levenick on 12/10/22.
//  Copyright © 2022 Levenick Enterprises LLC. All rights reserved.
//

import Cocoa
import Foundation

class InsecureSSLPopOver: NSViewController {
    
    let logMan = logManager()
    
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // Forces the window to be the size we want, not resizable
        preferredContentSize = NSSize(width: 450, height: 355)
    }
    
    @IBAction func btnAddingCertTokeychain(_ sender: Any) {
       if let url = URL(string: "https://support.apple.com/en-is/guide/keychain-access/kyca2431/mac") {
            if NSWorkspace.shared.open(url) {
                logMan.infoWrite(logString: "Opening Apple documentation on adding certificates to KeyChain.")
            }
        }
    }
    
    
    @IBAction func btnChangingTrustSettings(_ sender: Any) {
        if let url = URL(string: "https://support.apple.com/en-is/guide/keychain-access/kyca11871/mac") {
             if NSWorkspace.shared.open(url) {
                 logMan.infoWrite(logString: "Opening Apple documentation on changing trust settings for certificates.")
             }
         }
    }
    
}
