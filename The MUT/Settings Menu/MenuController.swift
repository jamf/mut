//
//  MenuController.swift
//  MUT
//
//  Created by Michael Levenick on 12/4/22.
//  Copyright © 2022 Levenick Enterprises LLC. All rights reserved.
//

import Cocoa
import Foundation

class MenuController: NSViewController {
    
    // Set up defaults to be able to save to and restore from
    let menuDefaults = UserDefaults.standard
    
    // This runs when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        SwitchTabs(selectedButton: btnGeneralOutlet, tabIdentifier: "General")
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // Forces the window to be the size we want, not resizable
        preferredContentSize = NSSize(width: 550, height: 290)
    }
    
    @IBOutlet weak var tabViewController: NSTabView!
    
    // Top menu outlets
    @IBOutlet weak var btnGeneralOutlet: NSButton!
    @IBOutlet weak var btnSecurityOutlet: NSButton!
    
    // General Menu Outlets
    @IBOutlet weak var popLogLevelOutlet: NSPopUpButton!
    @IBOutlet weak var chkDelimiterOutlet: NSButton!
    @IBOutlet weak var chkUsernameIntOutlet: NSButton!
    
    // Security Menu Outlets
    @IBOutlet weak var chkUntrustedSSLOutlet: NSButton!
    @IBOutlet weak var chkStoreURLOutlet: NSButton!
    @IBOutlet weak var chkStoreUsernameOutlet: NSButton!
    @IBOutlet weak var chkStoreUntrustedSSLOutlet: NSButton!
    @IBOutlet weak var chkStoreDelimiterOutlet: NSButton!
    
    // Menu Bar Actions
    @IBAction func btnGeneral(_ sender: Any) {
        SwitchTabs(selectedButton: btnGeneralOutlet, tabIdentifier: "General")
        preferredContentSize = NSSize(width: 550, height: 290)
    }
    
    @IBAction func btnSecurity(_ sender: Any) {
        preferredContentSize = NSSize(width: 550, height: 325)
        SwitchTabs(selectedButton: btnSecurityOutlet, tabIdentifier: "Security")
    }
    
    // General Menu Actions
    @IBAction func popLogLevel(_ sender: Any) {
    }
    
    @IBAction func btnOpenLog(_ sender: Any) {
    }
    
    @IBAction func chkDelimiter(_ sender: Any) {
    }
    
    @IBAction func chkUsernamesInts(_ sender: Any) {
    }
    
    
    // Security Menu Actions
    @IBAction func chkAllowUntrusted(_ sender: Any) {
    }
    
    @IBAction func btnClearKeychain(_ sender: Any) {
    }
    
    @IBAction func chkStoreURL(_ sender: Any) {
    }
    
    @IBAction func chkStoreUsername(_ sender: Any) {
    }
    
    @IBAction func chkStoreUntrusted(_ sender: Any) {
    }
    
    @IBAction func chkStoreDelimiter(_ sender: Any) {
    }
    
    
    func SwitchTabs(selectedButton: NSButton, tabIdentifier: String){
        // Array of all Button Outlets
        let buttons = [btnGeneralOutlet, btnSecurityOutlet]
        
        for button in buttons {
            button?.state = NSControl.StateValue.off
        }
        
        selectedButton.state = NSControl.StateValue.on
        tabViewController.selectTabViewItem(withIdentifier: tabIdentifier)
    }
    
    
    public 
}
