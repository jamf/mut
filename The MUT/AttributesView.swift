//
//  AttributesView.swift
//  The MUT
//
//  Created by Michael Levenick on 10/18/16.
//  Copyright © 2016 Levenick Enterprises LLC. All rights reserved.
//

// ATTRIBUTES PAGE

import Foundation
import Cocoa

class AttributesView: NSViewController {
    
    var globalPathToCSV: NSURL!
    
    @IBOutlet weak var popDeviceOutlet: NSPopUpButton!
    @IBOutlet weak var popIDOutlet: NSPopUpButton!
    @IBOutlet weak var popAttributeOutlet: NSPopUpButton!
    @IBOutlet weak var txtPathToCSV: NSTextField!
    
    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 600, height: 326)
        popAttributeOutlet.removeAllItems()
        popAttributeOutlet.addItem(withTitle: " Asset Tag")
        popAttributeOutlet.addItem(withTitle: " Username")
        popAttributeOutlet.addItem(withTitle: " Full Name")
        popAttributeOutlet.addItem(withTitle: " Email")
        popAttributeOutlet.addItem(withTitle: " Position")
        popAttributeOutlet.addItem(withTitle: " Department")
        popAttributeOutlet.addItem(withTitle: " Building")
        popAttributeOutlet.addItem(withTitle: " Room")
        popAttributeOutlet.addItem(withTitle: " Site by ID")
        popAttributeOutlet.addItem(withTitle: " Site by Name")
        popAttributeOutlet.addItem(withTitle: " Extension Attribute")
    }
    
    override func viewDidLoad() {

    }
    
    
    @IBAction func popDeviceAction(_ sender: Any) {
        
        if popDeviceOutlet.titleOfSelectedItem == " Users" {
            popIDOutlet.removeAllItems()
            popIDOutlet.addItems(withTitles: [" Username"," ID Number"])
            
            popAttributeOutlet.removeAllItems()
            popAttributeOutlet.addItems(withTitles: [" User's Username"," User's Full Name"," Email Address"," User's Position"," Phone Number"," User's Site by ID"," User's Site by Name"," User Extension Attribute"])
        }
        
        if popDeviceOutlet.titleOfSelectedItem == " iOS Devices" {
            popIDOutlet.removeAllItems()
            popIDOutlet.addItem(withTitle: " Serial Number")
            popIDOutlet.addItem(withTitle: " ID Number")
            
            popAttributeOutlet.removeAllItems()
            popAttributeOutlet.addItem(withTitle: " Asset Tag")
            popAttributeOutlet.addItem(withTitle: " Username")
            popAttributeOutlet.addItem(withTitle: " Full Name")
            popAttributeOutlet.addItem(withTitle: " Email")
            popAttributeOutlet.addItem(withTitle: " Position")
            popAttributeOutlet.addItem(withTitle: " Department")
            popAttributeOutlet.addItem(withTitle: " Building")
            popAttributeOutlet.addItem(withTitle: " Room")
            popAttributeOutlet.addItem(withTitle: " Site by ID")
            popAttributeOutlet.addItem(withTitle: " Site by Name")
            popAttributeOutlet.addItem(withTitle: " Extension Attribute")
        }
        
        if popDeviceOutlet.titleOfSelectedItem == " MacOS Devices" {
            popIDOutlet.removeAllItems()
            popIDOutlet.addItem(withTitle: " Serial Number")
            popIDOutlet.addItem(withTitle: " ID Number")
            
            popAttributeOutlet.removeAllItems()
            popAttributeOutlet.addItem(withTitle: " Device Name")
            popAttributeOutlet.addItem(withTitle: " Asset Tag")
            popAttributeOutlet.addItem(withTitle: " Username")
            popAttributeOutlet.addItem(withTitle: " Full Name")
            popAttributeOutlet.addItem(withTitle: " Email")
            popAttributeOutlet.addItem(withTitle: " Position")
            popAttributeOutlet.addItem(withTitle: " Department")
            popAttributeOutlet.addItem(withTitle: " Building")
            popAttributeOutlet.addItem(withTitle: " Room")
            popAttributeOutlet.addItem(withTitle: " Site by ID")
            popAttributeOutlet.addItem(withTitle: " Site by Name")
            popAttributeOutlet.addItem(withTitle: " Extension Attribute")
        }
    }
    
    @IBAction func popIDAction(_ sender: Any) {
        
    }
    
    @IBAction func popAttributeAction(_ sender: Any) {
    }
    
    @IBAction func btnBrowse(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["csv"]
        openPanel.begin { (result) in
            if result == NSFileHandlingPanelOKButton {
                //print(openPanel.URL!) //uncomment for debugging
                self.globalPathToCSV = openPanel.url! as NSURL!
                //print(self.globalPathToCSV.path!) //uncomment for debugging
                self.txtPathToCSV.stringValue = self.globalPathToCSV.path!
            }
        }

    }
    
    @IBAction func btnDismissAttributes(_ sender: AnyObject) {
        self.dismissViewController(self)
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        self.dismissViewController(self)
    }
    
}
