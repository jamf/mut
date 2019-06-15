//
//  ViewController.swift
//  The MUT v5
//
//  Created by Michael Levenick on 5/24/19.
//  Copyright © 2019 Michael Levenick. All rights reserved.
//

import Cocoa
import CSV
import Foundation

class ViewController: NSViewController, URLSessionDelegate, DataSentDelegate {
    
    // Declare outlets for Buttons to change color and hide/show
    @IBOutlet weak var btnSubmitOutlet: NSButton!
    @IBOutlet weak var btnPreFlightOutlet: NSButton!
    
    // Declare outlet for entire controller
    @IBOutlet var MainViewController: NSView!
    
    // Outlet for Logging text window and scroll view
    @IBOutlet var txtMain: NSTextView!
    @IBOutlet weak var txtMainWrapper: NSScrollView!
    
    // Progress bar and labels for runtime
    @IBOutlet weak var barProgress: NSProgressIndicator!
    @IBOutlet weak var lblCurrent: NSTextField!
    @IBOutlet weak var lblOf: NSTextField!
    @IBOutlet weak var lblEndLine: NSTextField!
    @IBOutlet weak var lblLine: NSTextField!
    
    // DropDowns for Attributes etc
    @IBOutlet weak var popAttributeOutlet: NSPopUpButton!
    @IBOutlet weak var popDeviceOutlet: NSPopUpButton!
    @IBOutlet weak var txtEAID: NSTextField!
    @IBOutlet weak var txtCSV: NSTextField!
    
    @IBOutlet weak var boxLog: NSBox!
    
    var globalPathToCSV: NSURL!
    var globalToken: String!
    var globalURL: String!
    var globalExpiry: Int!
    var globalBase64: String!
    
    func userDidAuthenticate(base64Credentials: String, url: String, token: String, expiry: Int) {
        globalExpiry = expiry
        globalToken = token
        globalURL = url
        globalBase64 = base64Credentials
    }
    
    let dataMan = dataManipulation()
    let tokenMan = tokenManagement()
    let xmlMan = xmlManager()
    let CSVMan = CSVManipulation()
    let APIFunc = APIFunctions()
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueLogin" {
            let loginWindow: loginWindow = segue.destinationController as! loginWindow
            loginWindow.delegateAuth = self as DataSentDelegate
        }
    }

    override func viewWillAppear() {
        //resize the view
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 450, height: 600)
        performSegue(withIdentifier: "segueLogin", sender: self)
    }
    
    
    @IBAction func btnBrowse(_ sender: Any) {
        //notReadyToRun() // OLD CODE
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["csv"]
        openPanel.begin { (result) in
            if result.rawValue == NSFileHandlingPanelOKButton {
                self.globalPathToCSV = openPanel.url! as NSURL
                self.txtCSV.stringValue = self.globalPathToCSV.path!
            }
        }
    }

    
    @IBAction func btnPreFlightAction(_ sender: Any) {
        submitUpdates()
        
    }
    
    @IBAction func btnExportCSV(_ sender: Any) {
        NSLog("[INFO  : Saving CSV Templates to User's Download's Directory")
        CSVMan.ExportCSV()
    }

    func submitUpdates() {
        NSLog("[INFO  : Beginning parsing the CSV file into the array stream.")
        let csvArray = CSVMan.readCSV(pathToCSV: self.globalPathToCSV.path ?? "/dev/null")
        let headerRow = csvArray[0]
        let numberOfColumns = headerRow.count
        for row in 1...(csvArray.count - 1) {
            let currentRow = csvArray[row]
            let xmlToPut = xmlMan.userObject(username: currentRow[0], full_name: currentRow[1], email_address: currentRow[2], phone_number: currentRow[3], position: currentRow[4], ldap_server: currentRow[5])
            let response = APIFunc.putData(passedUrl: globalURL, credentials: globalBase64, endpoint: "users", identifierType: "name", identifier: currentRow[0], allowUntrusted: false, xmlToPut: xmlToPut)
        }
    }
}
