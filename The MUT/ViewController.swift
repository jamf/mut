//
//  ViewController.swift
//  The MUT
//
//  Created by Michael Levenick on 10/17/16.
//  Copyright © 2018 Levenick Enterprises LLC. All rights reserved.
//
extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}

import Cocoa
import Foundation

class ViewController: NSViewController, URLSessionDelegate, DataSentDelegate {
    
    // MARK: - Declarations
    
    // Declare a bunch of global variables to use in various functions
    var globalServerURL: String!
    var globalServerCredentials: String!
    var globalCSVPath: String!
    var globalDeviceType: String!
    var globalIDType: String!
    var globalAttributeType: String!
    var globalEndpoint: String!
    var globalPathToCSV: NSURL!
    var globalXMLDevice: String!
    var globalEndpointID: String!
    var globalEAID: String!
    var delimiter = ","
    var globalCSVContent: String!
    var globalParsedCSV: CSwiftV!
    var doneCounter = 0
    var base64Credentials: String!
    var serverURL: String!
    var verified = false
    var columnChecker = 0
    var globalHTTPFunction: String!
    var myURL: URL!
    var globalDebug = "off"
    
    // Set up operation queue for runs
    let myOpQueue = OperationQueue()

    // Declare variable for defaults on main view
    let mainViewDefaults = UserDefaults.standard
    
    // Declare format for various logging fonts
    let myFontAttribute = [ NSFontAttributeName: NSFont(name: "Helvetica Neue Thin", size: 14.0)! ]
    let myHeaderAttribute = [ NSFontAttributeName: NSFont(name: "Helvetica Neue Thin", size: 20.0)! ]
    let myOKFontAttribute = [
        NSFontAttributeName: NSFont(name: "Courier", size: 14.0)!,
        NSForegroundColorAttributeName: NSColor(deviceRed: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
    ]
    let myFailFontAttribute = [
        NSFontAttributeName: NSFont(name: "Courier", size: 14.0)!,
        NSForegroundColorAttributeName: NSColor(deviceRed: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
    ]
    
    let myCSVFontAttribute = [ NSFontAttributeName: NSFont(name: "Courier", size: 14.0)! ]
    
    let myAlertFontAttribute = [
        NSFontAttributeName: NSFont(name: "Helvetica Neue Thin", size: 14.0)!,
        NSForegroundColorAttributeName: NSColor(deviceRed: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
    ]
    
    let myOffStateAttribute = [
        NSForegroundColorAttributeName: NSColor(deviceRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    ]

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

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueLogin" {
            let loginWindow: loginWindow = segue.destinationController as! loginWindow
            loginWindow.delegateAuth = self
        }
    }
    
    // MARK: - On load
    
    // Takes place right after view loads
    override func viewDidLoad() {
        super.viewDidLoad()

        // Print welcome message
        txtMain.textStorage?.append(NSAttributedString(string: "Welcome to The MUT v4", attributes: myHeaderAttribute))
        printLineBreak()
        printLineBreak()
        
        // Set up delimiter
        if mainViewDefaults.value(forKey: "Delimiter") != nil {
            delimiter = mainViewDefaults.value(forKey: "Delimiter")! as! String
            appendLogString(stringToAppend: "Stored delimiter found: \(delimiter)")
            printLineBreak()
        } else {
            appendLogString(stringToAppend: "No stored delimiter found. Using default of comma.")
            printLineBreak()
            delimiter = ","
        }
        appendLogString(stringToAppend: "Example CSV for macOS Username Updates:")
        appendLogString(stringToAppend: "(Including optional header)")
        appendCSV(stringToPrint: "+--------------------+-------------------+")
        appendCSV(stringToPrint: "| Serial Number      | Username          |")
        appendCSV(stringToPrint: "+--------------------+-------------------+")
        appendCSV(stringToPrint: "| C123456789         | mike.levenick     |")
        appendCSV(stringToPrint: "+--------------------+-------------------+")
        appendCSV(stringToPrint: "| C987654321         | alex.ekblad       |")
        appendCSV(stringToPrint: "+--------------------+-------------------+")
        printLineBreak()
        appendLogString(stringToAppend: "(Without optional header)")
        appendCSV(stringToPrint: "+--------------------+-------------------+")
        appendCSV(stringToPrint: "| C123456789         | mike.levenick     |")
        appendCSV(stringToPrint: "+--------------------+-------------------+")
        appendCSV(stringToPrint: "| C987654321         | alex.ekblad       |")
        appendCSV(stringToPrint: "+--------------------+-------------------+")
        
        // Set up the attribute outlet drop down
        popAttributeOutlet.removeAllItems()
        popAttributeOutlet.addItems(withTitles: ["Asset Tag","Barcode 1", "Barcode 2","Device Name","Username","Full Name","Email","Position","Department","Building","Room","Site by ID","Site by Name","Extension Attribute","Vendor","PO Number", "PO Date", "Warranty Expires", "Lease Expires", "ADD TO macOS Static Group", "REMOVE FROM macOS Static Group"])
    }
    
    override func viewWillAppear() {
        //resize the view
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 450, height: 600)
        performSegue(withIdentifier: "segueLogin", sender: self)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.isMovableByWindowBackground = true
    }

    // Set up the dropdown items depending on what record type is selected
    @IBAction func popDeviceAction(_ sender: Any) {
        notReadyToRun()
        if popDeviceOutlet.titleOfSelectedItem == "Users" {
            popAttributeOutlet.removeAllItems()
            popAttributeOutlet.addItems(withTitles: ["User's Username","User's Full Name","Email Address","User's Position","Phone Number","User's Site by ID","User's Site by Name","User Extension Attribute","LDAP Server","ADD TO User Static Group", "REMOVE FROM User Static Group"])
        }
        if popDeviceOutlet.titleOfSelectedItem == "iOS Devices" {
            popAttributeOutlet.removeAllItems()
            popAttributeOutlet.addItems(withTitles: ["Asset Tag","Device Name","Username","Full Name","Email","Position","Department","Building","Room","Site by ID","Site by Name","Extension Attribute","Vendor","PO Number", "PO Date", "Warranty Expires", "Lease Expires", "ADD TO iOS Static Group", "REMOVE FROM iOS Static Group"])
                    }
        if popDeviceOutlet.titleOfSelectedItem == "macOS Devices" {
            popAttributeOutlet.removeAllItems()
            popAttributeOutlet.addItems(withTitles: ["Asset Tag","Barcode 1","Barcode 2","Device Name","Username","Full Name","Email","Position","Department","Building","Room","Site by ID","Site by Name","Extension Attribute","PO Number","Vendor", "PO Date", "Warranty Expires", "Lease Expires", "ADD TO macOS Static Group", "REMOVE FROM macOS Static Group"])
        }
    }
    
    @IBAction func popAttributeAction(_ sender: Any) {
        notReadyToRun()
        if popAttributeOutlet.titleOfSelectedItem == "Extension Attribute" || popAttributeOutlet.titleOfSelectedItem == "User Extension Attribute" {
            txtEAID.isEnabled = true
        } else {
            txtEAID.isEnabled = false
        }
        if popAttributeOutlet.titleOfSelectedItem == "User Extension Attribute" {
            appendRed(stringToPrint: "")
        }
        if popAttributeOutlet.titleOfSelectedItem == "Site by ID" {
            appendRed(stringToPrint: "To remove a device from all sites, assign a device to Site ID '-1'.")
            printLineBreak()
        }
        if popAttributeOutlet.titleOfSelectedItem == "Site by Name" {
            appendRed(stringToPrint: "To remove a device from all sites, assign a device to Site Name 'None'.")
            printLineBreak()
        }
        if popAttributeOutlet.titleOfSelectedItem!.contains("Static Group") {
            appendRed(stringToPrint: "To add or remove a record in a static group, put the unique identifier (Serial Number or Jamf ID for devices, Username or Jamf ID for Users) in Column A, with the Group ID in Column B.")
            printLineBreak()
            appendRed(stringToPrint: "You must first manually create the group in Jamf Pro, and then you can find the Group ID in the URL when viewing the group.")
        }
        if popAttributeOutlet.titleOfSelectedItem == "Department" || popAttributeOutlet.titleOfSelectedItem == "Building" {
            appendRed(stringToPrint: "Jamf Pro does not create Department or Building on demand when you assign a device to them.")
            printLineBreak()
            appendRed(stringToPrint: "You must first manually create the Building or Department in Jamf Pro before being able to assign a device to one.")
        }
    }
    
    @IBAction func btnBrowse(_ sender: Any) {
        notReadyToRun()
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["csv"]
        openPanel.begin { (result) in
            if result == NSFileHandlingPanelOKButton {
                self.globalPathToCSV = openPanel.url! as NSURL!
                self.txtCSV.stringValue = self.globalPathToCSV.path!
            }
        }
    }
    
    func prepareToBuildXML() {
        btnSubmitOutlet.isHidden = false
        globalDeviceType = popDeviceOutlet.titleOfSelectedItem
        globalAttributeType = popAttributeOutlet.titleOfSelectedItem
        globalEAID = txtEAID.stringValue
        
        // MARK: - XML Building variables
        
        // Switches to set XML and Endpoint values
        switch (globalDeviceType) {
            case "iOS Devices" :
                globalXMLDevice = "mobile_device"
                globalEndpoint = "mobiledevices"
            case "macOS Devices" :
                globalXMLDevice = "computer"
                globalEndpoint = "computers"
            case "Users" :
                globalXMLDevice = "user"
                globalEndpoint = "users"
            default:
                print("Something Broke")
        }
        
        // Switches to set Identifier type
        //iOS
        if globalParsedCSV.rows.count > 0 {
            let row1 = globalParsedCSV.rows[0]
            if globalParsedCSV.rows.count > 1 {
                // MORE THAN ONE ROW, LOGICAL DETERMINATIONS
                let row2 = globalParsedCSV.rows[1]
                //iOS
                if globalXMLDevice == "mobile_device" {
                    if row2[0].isNumber {
                        print("logically it is an ID")
                        globalIDType = "ID"
                        globalEndpointID = "id"
                        appendLogString(stringToAppend: "MUT has logically detected IDs for the unique identifier.")
                        printLineBreak()
                        appendLogString(stringToAppend: "To override: include a header row specifying 'id' or 'serial' in Column A.")
                    } else {
                        print("logically it is a serial")
                        globalIDType = "Serial Number"
                        globalEndpointID = "serialnumber"
                        appendLogString(stringToAppend: "MUT has logically detected Serial Numbers for the unique identifier.")
                        printLineBreak()
                        appendLogString(stringToAppend: "To override: include a header row specifying 'id' or 'serial' in Column A.")
                    }
                    printLineBreak()
                }
                //macOS
                if globalXMLDevice == "computer" {
                    if row2[0].isNumber {
                        print("logically it is an ID")
                        globalIDType = "ID"
                        globalEndpointID = "id"
                        appendLogString(stringToAppend: "MUT has logically detected IDs for the unique identifier.")
                        printLineBreak()
                        appendLogString(stringToAppend: "To override: include a header row specifying 'id' or 'serial' in Column A.")
                    } else {
                        print("logically it is a serial")
                        globalIDType = "Serial Number"
                        globalEndpointID = "serialnumber"
                        appendLogString(stringToAppend: "MUT has logically detected Serial Numbers for the unique identifier.")
                        printLineBreak()
                        appendLogString(stringToAppend: "To override: include a header row specifying 'id' or 'serial' in Column A.")
                    }
                    printLineBreak()
                }
                //User
                if globalXMLDevice == "user" {
                    if row2[0].isNumber {
                        print("logically it is an ID")
                        globalIDType = "ID"
                        globalEndpointID = "id"
                        appendLogString(stringToAppend: "MUT has logically detected IDs for the unique identifier.")
                        printLineBreak()
                        appendLogString(stringToAppend: "To override: include a header row specifying 'id' or 'username' in Column A.")
                    } else {
                        print("logically it is a username")
                        globalIDType = "Username"
                        globalEndpointID = "name"
                        appendLogString(stringToAppend: "MUT has logically detected Usernames for the unique identifier.")
                        printLineBreak()
                        appendLogString(stringToAppend: "To override: include a header row specifying 'id' or 'username' in Column A.")
                    }
                    printLineBreak()
                }
            } else {
                // ONLY ONE ROW, LOGICAL DETERMINATIONS
                //iOS
                if globalXMLDevice == "mobile_device" {
                    if row1[0].isNumber {
                        globalIDType = "ID"
                        globalEndpointID = "id"
                        appendLogString(stringToAppend: "MUT has logically detected IDs for the unique identifier.")
                        printLineBreak()
                        appendLogString(stringToAppend: "To override: include a header row specifying 'id' or 'serial' in Column A.")
                    } else {
                        globalIDType = "Serial Number"
                        globalEndpointID = "serialnumber"
                        appendLogString(stringToAppend: "MUT has logically detected Serial Numbers for the unique identifier.")
                        printLineBreak()
                        appendLogString(stringToAppend: "To override: include a header row specifying 'id' or 'serial' in Column A.")
                    }
                    printLineBreak()
                }
                //macOS
                if globalXMLDevice == "computer" {
                    if row1[0].isNumber {
                        globalIDType = "ID"
                        globalEndpointID = "id"
                        appendLogString(stringToAppend: "MUT has logically detected IDs for the unique identifier.")
                        printLineBreak()
                        appendLogString(stringToAppend: "To override: include a header row specifying 'id' or 'serial' in Column A.")
                    } else {
                        globalIDType = "Serial Number"
                        globalEndpointID = "serialnumber"
                        appendLogString(stringToAppend: "MUT has logically detected Serial Numbers for the unique identifier.")
                        printLineBreak()
                        appendLogString(stringToAppend: "To override: include a header row specifying 'id' or 'serial' in Column A.")
                    }
                    printLineBreak()
                }
                //User
                if globalXMLDevice == "user" {
                    if row1[0].isNumber {
                        globalIDType = "ID"
                        globalEndpointID = "id"
                        appendLogString(stringToAppend: "MUT has logically detected IDs for the unique identifier.")
                        printLineBreak()
                        appendLogString(stringToAppend: "To override: include a header row specifying 'id' or 'username' in Column A.")
                    } else {
                        globalIDType = "Username"
                        globalEndpointID = "name"
                        appendLogString(stringToAppend: "MUT has logically detected Usernames for the unique identifier.")
                        printLineBreak()
                        appendLogString(stringToAppend: "To override: include a header row specifying 'id' or 'username' in Column A.")
                    }
                    printLineBreak()
                }
            }
            if row1[0].lowercased() == "id" {
                globalEndpointID = "id"
                globalIDType = "ID"
                appendLogString(stringToAppend: "Your header specifying IDs overrides the previous logical determination.")
                printLineBreak()
            }
            if row1[0].lowercased().contains("serial") {
                globalEndpointID = "serialnumber"
                globalIDType = "Serial Number"
                appendLogString(stringToAppend: "Your header specifying Serial Numbers overrides the previous logical determination.")
                printLineBreak()
            }
            if row1[0].lowercased() == "username" {
                globalEndpointID = "name"
                globalIDType = "Username"
                appendLogString(stringToAppend: "Your header specifying Usernames overrides the previous logical determination.")
                printLineBreak()
            }
        }
    }
    
    // Pass back the CSV Path
    func parseCSV() {
        globalCSVPath = txtCSV.stringValue
        // Parse the CSV into an array
        globalCSVContent = try! NSString(contentsOfFile: globalCSVPath, encoding: String.Encoding.utf8.rawValue) as String!
        globalParsedCSV = CSwiftV(with: globalCSVContent as String, separator: delimiter, headers: ["Device", "Attribute"])
        
        let columnCheck = globalParsedCSV.rows[0]
        let numberOfCommas = columnCheck.split(separator: delimiter, omittingEmptySubsequences: false)
        let newNumberOfCommas = numberOfCommas[0]
        columnChecker = newNumberOfCommas.count
        
    }
    
    // Clear Stored Values -- DO NOT DELETE
    // Although it appears to not be linked, it is tied to a menu option
    @IBAction func btnClearStored(_ sender: AnyObject) {
        //Clear all stored values
        if let bundle = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundle)
        }
    }
    
    // Change Delimiter -- DO NOT DELETE
    // Although it appears to not be linked, it is tied to a menu option
    @IBAction func btnChangeDelim(_ sender: AnyObject) {
        
        let newDelim = popPrompt().selectDelim(question: "Change Delimiter", text: "What would you like your new delimiter to be?")
        if newDelim == true {
            appendLogString(stringToAppend: "New delimiter is comma. This delimiter will be stored to defaults.")
            printLineBreak()
            delimiter = ","
            mainViewDefaults.set(delimiter, forKey: "Delimiter")
        } else {
            appendLogString(stringToAppend: "New delimiter is semi-colon. This delimiter will be stored to defaults.")
            printLineBreak()
            delimiter = ";"
            mainViewDefaults.set(delimiter, forKey: "Delimiter")
        }
    }
    
    //Pre Flight Checks
    @IBAction func btnPreFlight(_ sender: Any) {
        if verified {
            if txtCSV.stringValue != "" {
                parseCSV()
                prepareToBuildXML()
                displayPreFlightInfo()
                readyToRun()
                appendLogString(stringToAppend: "=====================================")
                appendLogString(stringToAppend: "Please review the above information. If everything looks good, press the submit button. Otherwise, please verify the dropdowns and your CSV file and run another pre-flight check.")
                appendLogString(stringToAppend: "=====================================")
                printLineBreak()
            } else {
                _ = popPrompt().generalWarning(question: "No CSV Path Found", text: "Please browse for a CSV file in order to continue.")
                return
            }
        } else {
            _ = popPrompt().generalWarning(question: "Please Verify Credentials", text: "Please enter your server URL, and the credentials for an administrator account, and then verify your credentials to continue.")
        }
    }
    
    func displayPreFlightInfo() {
        appendLogString(stringToAppend: "Found \(globalParsedCSV.rows.count) rows in the CSV.")
        printLineBreak()
        if columnChecker < 2 {
            self.appendRed(stringToPrint: "The MUT did not find at least two columns in your CSV. If you are trying to blank out values, please include headers so that it can find the second column.")
            printLineBreak()
        } else if columnChecker > 2 {
            self.appendRed(stringToPrint: "The MUT found more than two columns in your CSV. The first column should be your unique identifier (eg: serial) and the second column should be the value to be updated.")
            printLineBreak()
        } else {
            // Display a preview of row 1 if only 1 row, or row 2 otherwise (to not preview headers)
            if globalParsedCSV.rows.count > 1 {
                let line1 = globalParsedCSV.rows[1]
                if line1.count >= 2 {
                    self.appendLogString(stringToAppend: "Example row from your CSV:")
                    self.appendLogString(stringToAppend: "\(globalIDType!.replacingOccurrences(of: " ", with: "")): \(line1[0]), \(globalAttributeType!): \(line1[1])")
                } else {
                    self.appendRed(stringToPrint: "Not enough columns were found in your CSV!!!")
                    self.appendRed(stringToPrint: "You can set a custom delimiter under Settings in the menu bar if you wish.")
                }
            } else if globalParsedCSV.rows.count > 0 {
                let line1 = globalParsedCSV.rows[0]
                if line1.count >= 2 {
                    self.appendLogString(stringToAppend: "Example row from your CSV:")
                    self.appendLogString(stringToAppend: "\(globalIDType.replacingOccurrences(of: " ", with: "")): \(line1[0]), \(globalAttributeType!): \(line1[1])")
                } else {
                    self.appendRed(stringToPrint: "Not enough columns were found in your CSV!!!")
                    self.appendRed(stringToPrint: "You can set a custom delimiter under Settings in the menu bar if you wish.")
                }
            } else {
                appendRed(stringToPrint: "No rows found in your CSV!!!")
            }
            printLineBreak()
        }
        
    }
    
    // Run enforce name function if proper attributes are selected
    // Otherwise, run put data function and update attributes
    @IBAction func submitRequests(_ sender: Any) {
        if verified {
            if txtCSV.stringValue != "" {
                 parseCSV()
            } else {
                _ = popPrompt().generalWarning(question: "No CSV Path Found", text: "Please browse for a CSV file in order to continue.")
                return
            }
            prepareToBuildXML()
            if globalDeviceType == "iOS Devices" && globalAttributeType == "Device Name" {
                globalHTTPFunction = "POST"
                uploadData()
            } else {
                globalHTTPFunction = "PUT"
                uploadData()
            }
        } else {
            _ = popPrompt().generalWarning(question: "Please Verify Credentials", text: "Please enter your server URL, and the credentials for an administrator account, and then verify your credentials to continue.")
        }
    }
    
    // MARK: - UPLOAD DATA FUNCTION
    func uploadData() {
        
        // Async update the UI for the start of the run
        DispatchQueue.main.async {
            self.beginRunView()
        }
        // Declare variables needed for progress tracking
        var rowCounter = 0
        let row = globalParsedCSV.rows // Send parsed rows to an array
        let lastrow = row.count - 1
        var i = 0
        lblEndLine.stringValue = "\(row.count)"
        
        // Set the max concurrent ops to the selectable number
        myOpQueue.maxConcurrentOperationCount = 1
        
        // Semaphore causes the op queue to wait for responses before sending a new request
        let semaphore = DispatchSemaphore(value: 0)
        

        while i <= lastrow {
            // Sets the current row to the row of the loop
            let currentRow = row[i]
            
            // Add a PUT or POST request to the operation queue
            myOpQueue.addOperation {
                if self.globalHTTPFunction == "PUT" {
                    
                    // TODO clean this section up I hate this logic block soooooo much.
                    if self.popAttributeOutlet.titleOfSelectedItem != "ADD TO macOS Static Group" && self.popAttributeOutlet.titleOfSelectedItem != "ADD TO iOS Static Group" && self.popAttributeOutlet.titleOfSelectedItem != "ADD TO User Static Group" && self.popAttributeOutlet.titleOfSelectedItem != "REMOVE FROM macOS Static Group" && self.popAttributeOutlet.titleOfSelectedItem != "REMOVE FROM iOS Static Group" && self.popAttributeOutlet.titleOfSelectedItem != "REMOVE FROM User Static Group" {
                        self.myURL = xmlBuilder().createPUTURL(url: self.globalServerURL!, endpoint: self.globalEndpoint!, idType: self.globalEndpointID!, columnA: currentRow[0])
                    } else {
                        if self.popAttributeOutlet.titleOfSelectedItem!.contains("macOS Static Group") {
                            self.myURL = xmlBuilder().createMacGroupURL(url: self.globalServerURL!, columnB: currentRow[1])
                        }
                        
                        if self.popAttributeOutlet.titleOfSelectedItem!.contains("iOS Static Group") {
                            self.myURL = xmlBuilder().createiOSGroupURL(url: self.globalServerURL!, columnB: currentRow[1])
                        }
                        
                        if self.popAttributeOutlet.titleOfSelectedItem!.contains("User Static Group") {
                            self.myURL = xmlBuilder().createUserGroupURL(url: self.globalServerURL!, columnB: currentRow[1])
                        }
                    }
                    
                } else {
                    self.myURL = xmlBuilder().createPOSTURL(url: self.globalServerURL!)
                }
                
                let encodedXML = xmlBuilder().createXML(popIdentifier: self.globalEndpointID, popDevice: self.popDeviceOutlet.titleOfSelectedItem!, popAttribute: self.popAttributeOutlet.titleOfSelectedItem!, eaID: self.txtEAID.stringValue, columnB: currentRow[1], columnA: currentRow[0])
                
                let request = NSMutableURLRequest(url: self.myURL)
                request.httpMethod = self.globalHTTPFunction
                request.httpBody = encodedXML
                let configuration = URLSessionConfiguration.default
                configuration.httpAdditionalHeaders = ["Authorization" : "Basic \(self.globalServerCredentials!)", "Content-Type" : "text/xml", "Accept" : "text/xml"]
                let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
                let task = session.dataTask(with: request as URLRequest, completionHandler: {
                    (data, response, error) -> Void in
                    
                    // If debug mode is enabled, print out the full data from the curl
                    if let myData = String(data: data!, encoding: .utf8) {
                        if self.globalDebug == "on" {
                            self.appendLogString(stringToAppend: "Full Response Data:")
                            self.appendLogString(stringToAppend: myData)
                            self.printLineBreak()
                        }
                    }
                    
                    // If we got a response
                    if let httpResponse = response as? HTTPURLResponse {
                        
                        // If that response is a success response
                        if httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 {
                            DispatchQueue.main.async {
                                // Print information to the log box
                                self.printString(stringToPrint: "Device \(currentRow[0]) - ")
                                self.appendGreen(stringToPrint: "OK! - \(httpResponse.statusCode)")
                                // Update the progress bar
                                self.barProgress.doubleValue = Double(rowCounter)
                            }
                        } else {
                            // If that response is not a success response
                            DispatchQueue.main.async {
                                // Print information to the log box
                                self.printString(stringToPrint: "Device \(currentRow[0]) - ")
                                self.appendRed(stringToPrint: "Failed! - \(httpResponse.statusCode)!")
                                if httpResponse.statusCode == 404 {
                                    self.printLineBreak()
                                    self.appendLogString(stringToAppend: "HTTP 404 means 'not found'. There is no device with \(self.globalEndpointID!) \(currentRow[0]) enrolled in Jamf Pro.")
                                    self.printLineBreak()
                                }
                                if httpResponse.statusCode == 409 {
                                    self.printLineBreak()
                                    self.appendLogString(stringToAppend: "HTTP 409 is a generic error code code. Turn on Advanced Debugging from the settings menu at the top of the screen for more information.")
                                    self.printLineBreak()
                                }
                                // Update the progress bar
                                self.barProgress.doubleValue = Double(rowCounter)
                            }
                        }
                        // Increment the row counter and signal that the response was received
                        rowCounter += 1
                        semaphore.signal()
                        // Async update the row count label
                        DispatchQueue.main.async {
                            self.lblLine.stringValue = "\(rowCounter)"
                        }
                    }
                    // Log errors if received (we probably shouldn't ever end up needing this)
                    if error != nil {
                        _ = popPrompt().generalWarning(question: "Fatal Error", text: "The MUT received a fatal error while uploading. \n\n \(error!.localizedDescription)")
                    }
                })
                // Send the request and then wait for the semaphore signal
                task.resume()
                semaphore.wait()
                
                // If we're on the last row sent, update the UI to reset for another run
                if rowCounter == lastrow || lastrow == 0 {
                    DispatchQueue.main.async {
                        self.resetView()
                    }
                }
            }
            i += 1
        }
    }
    
    // MARK: - Cancel function
    // Allow cancelling the run early, and print verbose information if it happens
    @IBOutlet weak var btnCancelOutlet: NSButton!
    @IBAction func btnCancel(_ sender: Any) {
        myOpQueue.cancelAllOperations()
        DispatchQueue.main.async {
            self.appendRed(stringToPrint:        "*************************************************")
            self.appendLogString(stringToAppend: "               UPDATE RUN CANCELLED BY USER!")
            self.appendLogString(stringToAppend: "The request that has already been initiated will complete.")
            self.appendLogString(stringToAppend: "           All other requests have been cancelled.")
            self.appendRed(stringToPrint:        "*************************************************")
            self.resetView()
            
        }
    }
    // Enable Debug -- DO NOT DELETE
    // Although it appears to not be linked, it is tied to a menu option
    @IBAction func btnEnableDebug(_ sender: Any) {
        if globalDebug == "off" {
            globalDebug = "on"
        } else {
            globalDebug = "off"
        }
        self.appendLogString(stringToAppend: "Debug set to: " + self.globalDebug)
        self.printLineBreak()
    }
    
    
    // Save Log Text -- DO NOT DELETE
    // Although it appears to not be linked, it is tied to a menu option
    @IBAction func btnSaveLog(_ sender: Any) {
        // Get the current date/time and format it
        let currentDate = NSDate()
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "yyyy-MM-dd_HH.mm"
        let currentFormattedDate = dayTimePeriodFormatter.string(from: currentDate as Date)
        // Create a new save window
        let saveDialogue = NSSavePanel()
        saveDialogue.allowedFileTypes = ["log","txt"]
        saveDialogue.canCreateDirectories = true
        saveDialogue.isExtensionHidden = false
        saveDialogue.message = "Allowed file formats are .log and .txt."
        saveDialogue.nameFieldStringValue = "MUT-Output-\(currentFormattedDate)"
        saveDialogue.begin() { (result: Int) -> Void in
            if result == NSFileHandlingPanelOKButton {
                let logcontents = "\(self.txtMain.string!)"
                do {
                    try logcontents.write(toFile: (saveDialogue.url?.path)!, atomically: true, encoding: String.Encoding.ascii)
                } catch {
                    // error handling here
                }

            }
        }
    }
    
    
        
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    // Defining functions for writing/appending log information
    
    // Simple line break
    func printLineBreak() {
        self.txtMain.textStorage?.append(NSAttributedString(string: "\n", attributes: self.myFontAttribute))
        self.txtMain.scrollToEndOfDocument(self)
    }
    
    // Prints fixed point text with no line break after
    func printString(stringToPrint: String) {
        self.txtMain.textStorage?.append(NSAttributedString(string: "\(stringToPrint)", attributes: self.myFontAttribute))
        self.txtMain.scrollToEndOfDocument(self)
    }
    
    // Prints green fixed point text with line break after - "OK"
    func appendGreen(stringToPrint: String) {
        self.txtMain.textStorage?.append(NSAttributedString(string: "\(stringToPrint)\n", attributes: self.myOKFontAttribute))
        self.txtMain.scrollToEndOfDocument(self)
    }
    
    func appendCSV(stringToPrint: String) {
        self.txtMain.textStorage?.append(NSAttributedString(string: "\(stringToPrint)\n", attributes: self.myCSVFontAttribute))
        self.txtMain.scrollToEndOfDocument(self)
    }
    
    // Prints red fixed point text with line break after - "FAIL"
    func appendRed(stringToPrint: String) {
        self.txtMain.textStorage?.append(NSAttributedString(string: "\(stringToPrint)\n", attributes: self.myFailFontAttribute))
        self.txtMain.scrollToEndOfDocument(self)
    }
    
    // Prints red Helventica text with line break after - "FAIL"
    func appendAlert(stringToPrint: String) {
        self.txtMain.textStorage?.append(NSAttributedString(string: "\(stringToPrint)\n", attributes: self.myAlertFontAttribute))
        self.txtMain.scrollToEndOfDocument(self)
    }
    
    // Prints black fixed point text with line break after
    func appendLogString(stringToAppend: String) {
        self.txtMain.textStorage?.append(NSAttributedString(string: "\(stringToAppend)\n", attributes: self.myFontAttribute))
        self.txtMain.scrollToEndOfDocument(self)
    }
    
    // Clears the entire logging text field
    func clearLog() {
        self.txtMain.textStorage?.setAttributedString(NSAttributedString(string: "", attributes: self.myFontAttribute))
    }
    func readyToRun() {
        btnSubmitOutlet.isHidden = false
        btnPreFlightOutlet.isHidden = true
    }
    func notReadyToRun() {
        btnSubmitOutlet.isHidden = true
        btnPreFlightOutlet.isHidden = false
    }
    
    func resetView() {
        self.lblLine.isHidden = true
        self.lblCurrent.isHidden = true
        self.lblEndLine.isHidden = true
        self.lblOf.isHidden = true
        self.barProgress.isHidden = true
        self.btnSubmitOutlet.isHidden = false
        self.barProgress.doubleValue = 0.0
        self.lblLine.stringValue = "0"
        self.btnCancelOutlet.isHidden = true
    }
    
    func beginRunView() {
        self.appendLogString(stringToAppend: "Beginning Update Run!")
        self.printLineBreak()
        self.lblLine.isHidden = false
        self.lblCurrent.isHidden = false
        self.lblEndLine.isHidden = false
        self.lblOf.isHidden = false
        self.barProgress.isHidden = false
        self.barProgress.maxValue = Double(self.globalParsedCSV.rows.count)
        self.btnSubmitOutlet.isHidden = true
        self.btnCancelOutlet.isHidden = false
    }
    
    func userDidAuthenticate(base64Credentials: String, url: String) {
        //print(base64Credentials)
        self.globalServerCredentials = base64Credentials
        //print(url)
        self.globalServerURL = url
        verified = true
    }
    
}
