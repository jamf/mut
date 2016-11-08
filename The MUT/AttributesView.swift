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
import CSVImporter

// Protocol to pass back Attribute info and CSV path
protocol DataSentAttributes {
    func userDidEnterAttributes(updateAttributes: Array<Any>)
}
protocol DataSentPath {
    func userDidEnterPath(csvPath: String)
}

class AttributesView: NSViewController {
    
    // Variables for passing CSV Path and Attributes
    var delegateAttributes: DataSentAttributes? = nil
    var delegatePath: DataSentPath? = nil
    var globalPathToCSV: NSURL!
    
    // Declare outlets
    @IBOutlet weak var popDeviceOutlet: NSPopUpButton!
    @IBOutlet weak var popIDOutlet: NSPopUpButton!
    @IBOutlet weak var popAttributeOutlet: NSPopUpButton!
    @IBOutlet weak var txtPathToCSV: NSTextField!
    
    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 600, height: 326) // Set the view size
        
        // Set up the attribute outlet drop down
        popAttributeOutlet.removeAllItems()
        popAttributeOutlet.addItems(withTitles: [" Device Name"," Asset Tag"," Username"," Full Name"," Email"," Position"," Department"," Building"," Room"," Site by ID"," Site by Name"," Extension Attribute"])
    }
    
    // Set up the dropdown items depending on what record type is selected
    @IBAction func popDeviceAction(_ sender: Any) {
        
        if popDeviceOutlet.titleOfSelectedItem == " Users" {
            popIDOutlet.removeAllItems()
            popIDOutlet.addItems(withTitles: [" Username"," ID Number"])
            
            popAttributeOutlet.removeAllItems()
            popAttributeOutlet.addItems(withTitles: [" User's Username"," User's Full Name"," Email Address"," User's Position"," Phone Number"," User's Site by ID"," User's Site by Name"," User Extension Attribute"])
        }
        if popDeviceOutlet.titleOfSelectedItem == " iOS Devices" {
            popIDOutlet.removeAllItems()
            popIDOutlet.addItems(withTitles: [" Serial Number"," ID Number"])
            
            popAttributeOutlet.removeAllItems()
            popAttributeOutlet.addItems(withTitles: [" Device Name"," Asset Tag"," Username"," Full Name"," Email"," Position"," Department"," Building"," Room"," Site by ID"," Site by Name"," Extension Attribute"])
        }
        if popDeviceOutlet.titleOfSelectedItem == " MacOS Devices" {
            popIDOutlet.removeAllItems()
            popIDOutlet.addItems(withTitles: [" Serial Number"," ID Number"])
            
            popAttributeOutlet.removeAllItems()
            popAttributeOutlet.addItems(withTitles: [" Device name"," Asset Tag"," Username"," Full Name"," Email"," Position"," Department"," Building"," Room"," Site by ID"," Site by Name"," Extension Attribute"])
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
        self.delegateAttributes?.userDidEnterAttributes(updateAttributes: [popDeviceOutlet.titleOfSelectedItem!,popIDOutlet.titleOfSelectedItem!,popAttributeOutlet.titleOfSelectedItem!])
        self.delegatePath?.userDidEnterPath(csvPath: txtPathToCSV.stringValue)
        self.dismissViewController(self)
    }
    
    @IBAction func btnParse(_ sender: Any) {
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        self.dismissViewController(self)
    }
    
}
