//
//  KeychainDefaultsPopover.swift
//  MUT
//
//  Created by Michael Levenick on 1/24/23.
//  Copyright © 2023 Levenick Enterprises LLC. All rights reserved.
//

import Cocoa
import Foundation

class KeychainDefaultsPopover: NSViewController {
    
    let logMan = logManager()

    override func viewDidAppear() {
        super.viewDidAppear()
        // Forces the window to be the size we want, not resizable
        preferredContentSize = NSSize(width: 450, height: 425)
    }
    
    @IBAction func btnKeychainStorage(_ sender: Any) {
        if let url = URL(string: "https://support.apple.com/en-is/guide/security/secb0694df1a/web") {
             if NSWorkspace.shared.open(url) {
                 logMan.writeLog(level: .info, logString: "Opening Apple documentation on Keychain Storage.")
             }
         }
    }
    
    @IBAction func btnDefaultsStorage(_ sender: Any) {
        if let url = URL(string: "https://developer.apple.com/documentation/foundation/userdefaults") {
                    if NSWorkspace.shared.open(url) {
                        logMan.writeLog(level: .info, logString: "Opening Apple documentation on Defaults Storage.")
                    }
                }
    }
}
