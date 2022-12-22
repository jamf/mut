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
    
    let logMan = logManager()
    
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
        
        restoreGUI()
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
    
    // Menu Bar Actions
    @IBAction func btnGeneral(_ sender: Any) {
        SwitchTabs(selectedButton: btnGeneralOutlet, tabIdentifier: "General")
    }
    
    @IBAction func btnSecurity(_ sender: Any) {
        SwitchTabs(selectedButton: btnSecurityOutlet, tabIdentifier: "Security")
    }
    
    // General Menu Actions
    @IBAction func popLogLevel(_ sender: Any) {
        menuDefaults.set(popLogLevelOutlet.selectedTag(), forKey: "LogLevel")
    }
    
    @IBAction func btnOpenLog(_ sender: Any) {
        logMan.openLog()
    }
    
    @IBAction func chkDelimiter(_ sender: Any) {
    }
    
    @IBAction func chkUsernamesInts(_ sender: Any) {
    }
    
    
    // Security Menu Actions
    @IBAction func chkAllowUntrusted(_ sender: Any) {
    }
    
    @IBAction func btnClearKeychain(_ sender: Any) {
        DispatchQueue.global(qos: .background).async {
            do {
                try KeyChainHelper.delete()
                self.logMan.infoWrite(logString: "Deleting information stored in keychain.")
            } catch KeychainError.noPassword {
                // No info found in keychain
                self.logMan.infoWrite(logString: "No stored info found in KeyChain.")
            } catch KeychainError.unexpectedPasswordData {
                // Info found, but it was bad
                self.logMan.errorWrite(logString: "Information was found in KeyChain, but it was somehow corrupt.")
            } catch {
                // Something else
                self.logMan.fatalWrite(logString: "Unhandled exception found with extracting KeyChain info.")
            }
        }
    }
    
    @IBAction func chkStoreURL(_ sender: Any) {
    }
    
    @IBAction func chkStoreUsername(_ sender: Any) {
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
    
    func restoreGUI(){
        if menuDefaults.value(forKey: "UserName") != nil {
            chkStoreUsernameOutlet.state = NSControl.StateValue.on
        }

        if menuDefaults.value(forKey: "InstanceURL") != nil {
            chkStoreURLOutlet.state = NSControl.StateValue.on
        }

        if menuDefaults.bool(forKey: "AllowUntrusted") == true {
            chkStoreURLOutlet.state = NSControl.StateValue.on
        }

        if menuDefaults.bool(forKey: "Delimiter") == true {
            chkDelimiterOutlet.state = NSControl.StateValue.on
        }

        if menuDefaults.bool(forKey: "UserInts") == true {
            chkUsernameIntOutlet.state = NSControl.StateValue.on
        }
        
        if menuDefaults.value(forKey: "LogLevel") != nil {
            popLogLevelOutlet.selectItem(withTag: menuDefaults.integer(forKey: "LogLevel"))
        }
    }
}
