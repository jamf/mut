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
        preferredContentSize = NSSize(width: 550, height: 290)
    }
    
    @IBAction func btnSecurity(_ sender: Any) {
        SwitchTabs(selectedButton: btnSecurityOutlet, tabIdentifier: "Security")
        preferredContentSize = NSSize(width: 550, height: 320)
    }
    
    // General Menu Actions
    @IBAction func popLogLevel(_ sender: Any) {
        menuDefaults.set(popLogLevelOutlet.selectedTag(), forKey: "LogLevel")
    }
    
    @IBAction func btnOpenLog(_ sender: Any) {
        logMan.openLog()
    }
    
    @IBAction func chkDelimiter(_ sender: Any) {
        if chkDelimiterOutlet.state == NSControl.StateValue.on {
            menuDefaults.set(";", forKey: "Delimiter")
            logMan.writeLog(level: .info, logString: "The new delimiter is semi-colon. This delimiter will be stored to defaults.")
        } else {
            menuDefaults.removeObject(forKey: "Delimiter")
            logMan.writeLog(level: .info, logString: "Removing semi-colon delimiter from defaults storage. Comma delimiter will be used.")
        }
    }
    
    @IBAction func chkUsernamesInts(_ sender: Any) {
        if chkUsernameIntOutlet.state == NSControl.StateValue.on {
            menuDefaults.set(true, forKey: "UserInts")
        } else {
            menuDefaults.removeObject(forKey: "UserInts")
        }
    }
    
    // Security Menu Actions
    @IBAction func chkAllowUntrusted(_ sender: Any) {
        if chkUntrustedSSLOutlet.state == NSControl.StateValue.on {
            menuDefaults.set(true, forKey: "Insecure")
        } else {
            menuDefaults.removeObject(forKey: "Insecure")
        }
    }
    
    @IBAction func btnClearKeychain(_ sender: Any) {
        if popPrompt().clearKeychain() {
            DispatchQueue.global(qos: .background).async {
                do {
                    try KeyChainHelper.delete()
                    self.logMan.writeLog(level: .info, logString: "Deleting information stored in keychain.")
                } catch KeychainError.noPassword {
                    // No info found in keychain
                    self.logMan.writeLog(level: .info, logString: "No stored info found in KeyChain.")
                } catch KeychainError.unexpectedPasswordData {
                    // Info found, but it was bad
                    self.logMan.writeLog(level: .error, logString: "Information was found in KeyChain, but it was somehow corrupt.")
                } catch {
                    // Something else
                    self.logMan.writeLog(level: .fatal, logString: "Unhandled exception found with extracting KeyChain info.")
                }
            }
        }
    }
    
    @IBAction func chkStoreURL(_ sender: Any) {
        if chkStoreURLOutlet.state == NSControl.StateValue.on {
            menuDefaults.set(true, forKey: "StoreURL")
        } else {
            menuDefaults.removeObject(forKey: "StoreURL")
        }
    }
    
    @IBAction func chkStoreUsername(_ sender: Any) {
        if chkStoreUsernameOutlet.state == NSControl.StateValue.on {
            menuDefaults.set(true, forKey: "StoreUsername")
        } else {
            menuDefaults.removeObject(forKey: "StoreUsername")
        }
    }
    
    @IBAction func btnHardReset(_ sender: Any) {
        if popPrompt().hardReset() {
            
            // Clear the keychain
            DispatchQueue.global(qos: .background).async {
                do {
                    try KeyChainHelper.delete()
                    self.logMan.writeLog(level: .info, logString: "Deleting information stored in keychain.")
                } catch KeychainError.noPassword {
                    // No info found in keychain
                    self.logMan.writeLog(level: .info, logString: "No stored info found in KeyChain.")
                } catch KeychainError.unexpectedPasswordData {
                    // Info found, but it was bad
                    self.logMan.writeLog(level: .error, logString: "Information was found in KeyChain, but it was somehow corrupt.")
                } catch {
                    // Something else
                    self.logMan.writeLog(level: .fatal, logString: "Unhandled exception found with extracting KeyChain info.")
                }
            }
            
            // Clear all stored defaults
            if let bundle = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundle)
            }
            exit(0)
        }
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
        if menuDefaults.bool(forKey: "StoreUsername") {
            chkStoreUsernameOutlet.state = NSControl.StateValue.on
        }

        if menuDefaults.bool(forKey: "StoreURL") {
            chkStoreURLOutlet.state = NSControl.StateValue.on
        }

        if menuDefaults.bool(forKey: "Insecure") {
            chkUntrustedSSLOutlet.state = NSControl.StateValue.on
        }

        if menuDefaults.string(forKey: "Delimiter") == ";" {
            chkDelimiterOutlet.state = NSControl.StateValue.on
        }

        if menuDefaults.bool(forKey: "UserInts") {
            chkUsernameIntOutlet.state = NSControl.StateValue.on
        }
        
        if menuDefaults.value(forKey: "LogLevel") != nil {
            popLogLevelOutlet.selectItem(withTag: menuDefaults.integer(forKey: "LogLevel"))
        }
    }
}
