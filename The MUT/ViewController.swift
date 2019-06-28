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
    var globalEndpoint: String!
    var xmlToPut: Data!
    
    func userDidAuthenticate(base64Credentials: String, url: String, token: String, expiry: Int) {
        globalExpiry = expiry
        globalToken = token
        globalURL = url
        globalBase64 = base64Credentials
    }
    
    let dataPrep = dataPreparation()
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
        //testUpdates()
        
    }
    
    @IBAction func btnExportCSV(_ sender: Any) {
        NSLog("[INFO  : Saving CSV Templates to User's Download's Directory")
        CSVMan.ExportCSV()
    }
    
    @IBAction func submitRequests(_ sender: Any) {
        
    }

    func submitUpdates() {
        // Begin the parse
        NSLog("[INFO  : Beginning parsing the CSV file into the array stream.")
        let csvArray = CSVMan.readCSV(pathToCSV: self.globalPathToCSV.path ?? "/dev/null")
        
        // Set variables needed for the run
        var ea_ids = [String]()
        var ea_values = [String]()
        let headerRow = csvArray[0]
        let numberOfColumns = headerRow.count
        globalEndpoint = dataPrep.endpoint(headerA: headerRow[0])
        print(globalEndpoint!)
        
        // Get the expected columns based off update type and calculate number of EAs present
        let expectedColumns = dataPrep.expectedColumns(endpoint: globalEndpoint!)
        let numberOfEAs = numberOfColumns - expectedColumns
        
        // If there are EAs, get a list of their EA IDs
        if numberOfEAs > 0 {
            ea_ids = dataPrep.eaIDs(expectedColumns: expectedColumns, numberOfColumns: numberOfColumns, headerRow: headerRow)
        }
        
        // Begin looping through the CSV sheet
        
        print(csvArray.count)
        if csvArray.count > 1 {
            for row in 1...(csvArray.count - 1) {
                ea_values = [] // Reset the EA_values so that we aren't just appending
                
                // Get the current row of the CSV for updating
                let currentRow = csvArray[row]
                
                // Populate the ea_values array if there are EAs to update
                if numberOfEAs > 0 {
                    ea_values = dataPrep.eaValues(expectedColumns: expectedColumns, numberOfColumns: numberOfColumns, currentRow: currentRow)
                }
                
                if globalEndpoint! == "users" {
                    // Generate the XML to submit
                    xmlToPut = xmlMan.userObject(username: currentRow[0], full_name: currentRow[1], email_address: currentRow[2], phone_number: currentRow[3], position: currentRow[4], ldap_server: currentRow[5], ea_ids: ea_ids, ea_values: ea_values, site_ident: "1")
                } else if globalEndpoint! == "computers" {
                    xmlToPut = xmlMan.macosObject(displayName: currentRow[1], assetTag: currentRow[2], barcode1: currentRow[3], barcode2: currentRow[4], username: currentRow[5], full_name: currentRow[6], email_address: currentRow[7], phone_number: currentRow[9], position: currentRow[8], department: currentRow[10], building: currentRow[11], room: currentRow[12], poNumber: currentRow[13], vendor: currentRow[14], poDate: currentRow[15], warrantyExpires: currentRow[16], leaseExpires: currentRow[17], ea_ids: ea_ids, ea_values: ea_values, site_ident: currentRow[18])
                } else if globalEndpoint! == "mobiledevices" {
                    xmlToPut = xmlMan.iosObject(displayName: currentRow[1], assetTag: currentRow[2], username: currentRow[3], full_name: currentRow[4], email_address: currentRow[5], phone_number: currentRow[7], position: currentRow[6], department: currentRow[8], building: currentRow[9], room: currentRow[10], poNumber: currentRow[11], vendor: currentRow[12], poDate: currentRow[13], warrantyExpires: currentRow[14], leaseExpires: currentRow[15], ea_ids: ea_ids, ea_values: ea_values, site_ident: currentRow[16])
                }
                let xmlString = String(decoding: xmlToPut, as: UTF8.self)
                print(xmlString)

                
                // Submit the XML to the Jamf Pro API
                let response = APIFunc.putData(passedUrl: globalURL, credentials: globalBase64, endpoint: globalEndpoint!, identifierType: "serialnumber", identifier: currentRow[0], allowUntrusted: false, xmlToPut: xmlToPut)
                print(response)
            }
        } else {
            // Not enough rows in the CSV to run
        }
    }

    func testUpdates() {
        let iOSXML = xmlMan.iosObject(displayName: "Mikes Mini", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "1")
        let response = APIFunc.putData(passedUrl: globalURL, credentials: globalBase64, endpoint: "mobiledevices", identifierType: "id", identifier: "81", allowUntrusted: false, xmlToPut: iOSXML)
        print(response)
        
    }
    
}
