//
//  ViewController.swift
//  The MUT
//
//  Created by Michael Levenick on 10/17/16.
//  Copyright © 2016 Levenick Enterprises LLC. All rights reserved.
//


import Cocoa
import Foundation

class ViewController: NSViewController, URLSessionDelegate {
    
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
    let myFontAttribute = [ NSFontAttributeName: NSFont(name: "Courier", size: 12.0)! ]
    let myHeaderAttribute = [ NSFontAttributeName: NSFont(name: "Helvetica Neue Thin", size: 18.0)! ]
    let myOKFontAttribute = [
        NSFontAttributeName: NSFont(name: "Courier", size: 12.0)!,
        NSForegroundColorAttributeName: NSColor(deviceRed: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
    ]
    let myFailFontAttribute = [
        NSFontAttributeName: NSFont(name: "Courier", size: 12.0)!,
        NSForegroundColorAttributeName: NSColor(deviceRed: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
    ]

    // Declare outlets for Buttons to change color and hide/show
    @IBOutlet weak var btnSubmitOutlet: NSButton!
    @IBOutlet weak var btnAcceptOutlet: NSButton!
    @IBOutlet weak var btnStoreUser: NSButton!
    @IBOutlet weak var spinWheel: NSProgressIndicator!
    @IBOutlet weak var btnPreFlightOutlet: NSButton!
    
    // Declare Text Boxes
    @IBOutlet weak var txtUser: NSTextField!
    @IBOutlet weak var txtPass: NSSecureTextField!
    
    // Declarations for Server Name
    @IBOutlet weak var radioHosted: NSButton!
    @IBOutlet weak var radioPrem: NSButton!
    @IBOutlet weak var txtPrem: NSTextField!
    @IBOutlet weak var txtHosted: NSTextField!


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
    @IBOutlet weak var popIDOutlet: NSPopUpButton!
    @IBOutlet weak var txtEAID: NSTextField!
    @IBOutlet weak var txtCSV: NSTextField!
    
    @IBOutlet weak var chkBypass: NSButton!
    
    // MARK: - On load
    
    // Takes place right after view loads
    override func viewDidLoad() {
        super.viewDidLoad()

        // Print welcome message
        txtMain.textStorage?.append(NSAttributedString(string: "Welcome to The MUT v3.6.0", attributes: myHeaderAttribute))
        printLineBreak()
        printLineBreak()
        
        // Restoring Username if not null
        if mainViewDefaults.value(forKey: "UserName") != nil {
            printString(stringToPrint: "Stored Username: ")
            appendLogString(stringToAppend: mainViewDefaults.value(forKey: "UserName") as! String)
                txtUser.stringValue = mainViewDefaults.value(forKey: "UserName") as! String
            printLineBreak()
                btnStoreUser.state = 1
        }
        
        // Restore Instance Name if Hosted
        if mainViewDefaults.value(forKey: "HostedInstanceName") != nil {
            txtHosted.stringValue = mainViewDefaults.value(forKey: "HostedInstanceName") as! String
        }
        
        // Restore Prem URL if on prem
        if mainViewDefaults.value(forKey: "PremInstanceURL") != nil {
            txtPrem.stringValue = mainViewDefaults.value(forKey: "PremInstanceURL") as! String
            radioPrem.state = 1
            txtPrem.becomeFirstResponder()
            txtHosted.isEnabled = false
            txtPrem.isEnabled = true
        }
        
        // Set up delimiter
        if mainViewDefaults.value(forKey: "Delimiter") != nil {
            delimiter = mainViewDefaults.value(forKey: "Delimiter")! as! String
            appendLogString(stringToAppend: "Stored delimiter found: \(delimiter)")
            printLineBreak()
        } else {
            appendLogString(stringToAppend: "No stored delimiter found. Using default of comma. You can change this under Settings in the menu bar if you wish.")
            printLineBreak()
            delimiter = ","
        }
        
        // Set up the attribute outlet drop down
        popAttributeOutlet.removeAllItems()
        popAttributeOutlet.addItems(withTitles: ["Asset Tag","Barcode 1", "Barcode 2","Device Name","Username","Full Name","Email","Position","Department","Building","Room","Site by ID","Site by Name","Extension Attribute","Vendor","PO Number", "PO Date", "Warranty Expires", "Lease Expires", "macOS Static Group"])

    }
    
    override func viewWillAppear() {
        //resize the view
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 540, height: 628)
        
    }
    
    //Unique Identifier Dropdown to show pre-flight again
    @IBAction func popIdentifierAction(_ sender: Any) {
        notReadyToRun()
    }
    
    @IBAction func radioServer(_ sender: NSButton) {
        notReadyToRun()
        // Disable On-Prem if Hosted = TRUE
        if radioHosted.state == 1 {
            txtPrem.isEnabled = false
            txtHosted.isEnabled = true
            txtHosted.becomeFirstResponder()
            
            // Else Disable Hosted if Hosted = FALSE
        } else {
            txtHosted.isEnabled = false
            txtPrem.isEnabled = true
            txtPrem.becomeFirstResponder()
        }
    }
    
    // Set up the dropdown items depending on what record type is selected
    @IBAction func popDeviceAction(_ sender: Any) {
        notReadyToRun()
        if popDeviceOutlet.titleOfSelectedItem == "Users" {
            popIDOutlet.removeAllItems()
            popIDOutlet.addItems(withTitles: ["Username","ID Number"])
            popAttributeOutlet.removeAllItems()
            popAttributeOutlet.addItems(withTitles: ["User's Username","User's Full Name","Email Address","User's Position","Phone Number","User's Site by ID","User's Site by Name","User Extension Attribute","User Static Group","LDAP Server"])
        }
        if popDeviceOutlet.titleOfSelectedItem == "iOS Devices" {
            popAttributeOutlet.removeAllItems()
            popAttributeOutlet.addItems(withTitles: ["Asset Tag","Device Name","Username","Full Name","Email","Position","Department","Building","Room","Site by ID","Site by Name","Extension Attribute","Vendor","PO Number", "PO Date", "Warranty Expires", "Lease Expires", "iOS Static Group"])
            if popAttributeOutlet.titleOfSelectedItem == "Device Name" {
                popIDOutlet.removeAllItems()
                popIDOutlet.addItems(withTitles: ["Serial Number"])
            } else {
                popIDOutlet.removeAllItems()
                popIDOutlet.addItems(withTitles: ["Serial Number","ID Number"])
            }
                    }
        if popDeviceOutlet.titleOfSelectedItem == "macOS Devices" {
            popIDOutlet.removeAllItems()
            popIDOutlet.addItems(withTitles: ["Serial Number","ID Number"])
            
            popAttributeOutlet.removeAllItems()
            popAttributeOutlet.addItems(withTitles: ["Asset Tag","Barcode 1","Barcode 2","Device Name","Username","Full Name","Email","Position","Department","Building","Room","Site by ID","Site by Name","Extension Attribute","PO Number","Vendor", "PO Date", "Warranty Expires", "Lease Expires", "macOS Static Group"])
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
        if popAttributeOutlet.titleOfSelectedItem == "macOS Static Group" || popAttributeOutlet.titleOfSelectedItem == "iOS Static Group" {
            appendRed(stringToPrint: "To assign Devices to a static group, put the device identifier (Serial Number or JSS ID) in Column A, with the Group ID in Column B.")
            printLineBreak()
            appendRed(stringToPrint: "You must first manually create the group in the JSS, and then you can find the Group ID in the URL when viewing the group.")
        }
        if popAttributeOutlet.titleOfSelectedItem == "Department" || popAttributeOutlet.titleOfSelectedItem == "Building" {
            appendRed(stringToPrint: "The JSS does not create Department or Building on demand when you assign a device to them.")
            printLineBreak()
            appendRed(stringToPrint: "You must first manually create the Building or Department in the JSS before being able to assign a device to one.")
        }
        if popDeviceOutlet.titleOfSelectedItem == "iOS Devices" {
            if popAttributeOutlet.titleOfSelectedItem == "Device Name" {
                popIDOutlet.removeAllItems()
                popIDOutlet.addItems(withTitles: ["Serial Number"])
            } else {
                popIDOutlet.removeAllItems()
                popIDOutlet.addItems(withTitles: ["Serial Number","ID Number"])
            }
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

    
    // MARK: - Verify Credentials
    @IBAction func btnAcceptCredentials(_ sender: AnyObject) {
        
        if radioHosted.state == 1 {
            if txtHosted.stringValue != "" {
                
                // Add JSS Resource and jamfcloud info
                serverURL = "https://\(txtHosted.stringValue).jamfcloud.com/JSSResource/"
                
                // Save the hosted instance and wipe saved prem server
                let instanceName = txtHosted.stringValue
                mainViewDefaults.set(instanceName, forKey: "HostedInstanceName")
                mainViewDefaults.set(serverURL!, forKey: "ServerURL")
                mainViewDefaults.removeObject(forKey: "PremInstanceURL")
                
                mainViewDefaults.synchronize()
                let cleanURL = serverURL!.replacingOccurrences(of: "JSSResource/", with: "")
                appendLogString(stringToAppend: "URL: \(cleanURL)")
                printLineBreak()
                
            } else {
                // If no URL is filled, warn user
                _ = popPrompt().generalWarning(question: "No Server Info", text: "You have selected the option for a hosted Jamf server, but no instance name was entered. Please enter your instance name and try again.")
            }
        }
        
        // If Prem Radio Chekced
        if radioPrem.state == 1 {
            
            // Check if URL is filled
            if txtPrem.stringValue != "" {
                
                // Add JSS Resource and remove double slashes
                serverURL = "\(txtPrem.stringValue)/JSSResource/"
                serverURL = serverURL.replacingOccurrences(of: "//JSSResource", with: "/JSSResource")
                
                // Save the prem URL and wipe saved hosted names
                let serverSave = txtPrem.stringValue
                mainViewDefaults.set(serverSave, forKey: "PremInstanceURL")
                mainViewDefaults.set(serverURL!, forKey: "ServerURL")
                mainViewDefaults.removeObject(forKey: "HostedInstanceName")
                mainViewDefaults.synchronize()
                let cleanURL = serverURL!.replacingOccurrences(of: "JSSResource/", with: "")
                appendLogString(stringToAppend: "URL: \(cleanURL)")
                
            } else {
                // If no URL is filled, warn user
                _ = popPrompt().generalWarning(question: "No Server Info", text: "You have selected the option for an on prem server, but no server URL was entered. Please enter your instance name and try again.")
            }
        }
        
        if serverURL != nil {
            btnAcceptOutlet.isHidden = true
            spinWheel.startAnimation(self)
            let concatCredentials = "\(txtUser.stringValue):\(txtPass.stringValue)"
            let utf8Credentials = concatCredentials.data(using: String.Encoding.utf8)
            base64Credentials = utf8Credentials?.base64EncodedString()
            
            if txtUser.stringValue != "" && txtPass.stringValue != "" {
                
                DispatchQueue.main.async {
                    let myURL = xmlBuilder().createGETURL(url: self.serverURL!)
                    let request = NSMutableURLRequest(url: myURL)
                    request.httpMethod = "GET"
                    let configuration = URLSessionConfiguration.default
                    configuration.httpAdditionalHeaders = ["Authorization" : "Basic \(self.base64Credentials!)", "Content-Type" : "text/xml", "Accept" : "text/xml"]
                    let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
                    let task = session.dataTask(with: request as URLRequest, completionHandler: {
                        (data, response, error) -> Void in
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode >= 199 && httpResponse.statusCode <= 299 {
                                self.globalServerCredentials = self.base64Credentials
                                self.globalServerURL = self.serverURL
                                self.appendLogString(stringToAppend: "Credentials Successfully Verified.")
                                self.printLineBreak()
                                self.verified = true
                                
                                // Store username if button pressed
                                if self.btnStoreUser.state == 1 {
                                    self.mainViewDefaults.set(self.txtUser.stringValue, forKey: "UserName")
                                    self.mainViewDefaults.synchronize()

                                } else {
                                    self.mainViewDefaults.removeObject(forKey: "UserName")
                                    self.mainViewDefaults.synchronize()
                                }
                                self.spinWheel.stopAnimation(self)
                                self.btnAcceptOutlet.isHidden = false

                            } else {
                                DispatchQueue.main.async {
                                    self.spinWheel.stopAnimation(self)
                                    self.btnAcceptOutlet.isHidden = false
                                    _ = popPrompt().generalWarning(question: "Invalid Credentials", text: "The credentials you entered do not seem to have sufficient permissions. This could be due to an incorrect user/password, or possibly from insufficient permissions. MUT tests this against the user's ability to view the Activation Code via the API.")
                                    if self.chkBypass.state == 1 {
                                        print("BYPASSED")
                                        self.globalServerCredentials = self.base64Credentials
                                        self.globalServerURL = self.serverURL
                                        self.appendLogString(stringToAppend: "Credential Verification Bypassed - USE WITH CAUTION.")
                                        self.printLineBreak()
                                        self.verified = true
                                    }
                                    
                                }
                            }
                        }
                        if error != nil {
                            _ = popPrompt().generalWarning(question: "Fatal Error", text: "The MUT received a fatal error at authentication. The most common cause of this is an incorrect server URL. The full error output is below. \n\n \(error!.localizedDescription)")
                            self.spinWheel.stopAnimation(self)
                            self.btnAcceptOutlet.isHidden = false
                        }
                    })
                    task.resume()
                }
            } else {
                _ = popPrompt().generalWarning(question: "Missing Credentials", text: "Either the username or the password field was left blank. Please fill in both the username and password field to verify credentials.")
                self.spinWheel.stopAnimation(self)
                self.btnAcceptOutlet.isHidden = false
            }
        }
    }

    
    
    func prepareToBuildXML() {
        btnSubmitOutlet.isHidden = false
        globalDeviceType = popDeviceOutlet.titleOfSelectedItem
        globalIDType = popIDOutlet.titleOfSelectedItem
        globalAttributeType = popAttributeOutlet.titleOfSelectedItem
        globalEAID = txtEAID.stringValue
        appendLogString(stringToAppend: "Device Type: \(globalDeviceType!)")
        appendLogString(stringToAppend: "ID Type: \(globalIDType!)")
        appendLogString(stringToAppend: "Attribute Type: \(globalAttributeType!)")
        printLineBreak()
        
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
        switch (globalIDType) {
            case "Serial Number" :
                globalEndpointID = "serialnumber"
            case "ID Number" :
                globalEndpointID = "id"
            case "Username" :
                globalEndpointID = "name"
            default:
                print("Something Broke")
        }
    }
    
    // Pass back the CSV Path
    func parseCSV() {
        
        globalCSVPath = txtCSV.stringValue
        appendLogString(stringToAppend: "CSV: \(globalCSVPath!)")
        
        // Parse the CSV into an array
        globalCSVContent = try! NSString(contentsOfFile: globalCSVPath, encoding: String.Encoding.utf8.rawValue) as String!
        globalParsedCSV = CSwiftV(with: globalCSVContent as String, separator: delimiter, headers: ["Device", "Attribute"])
        
        appendLogString(stringToAppend: "Found \(globalParsedCSV.rows.count) rows in the CSV.")
        printLineBreak()
        let columnCheck = globalParsedCSV.rows[0]
        let numberOfCommas = columnCheck.split(separator: delimiter, omittingEmptySubsequences: false)
        let newNumberOfCommas = numberOfCommas[0]
        columnChecker = newNumberOfCommas.count
        
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
    
    @IBAction func btnClearStored(_ sender: AnyObject) {
        //Clear all stored values
        if let bundle = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundle)
        }
    }
    
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

            prepareToBuildXML()
            
            if txtCSV.stringValue != "" {
                parseCSV()
                readyToRun()
                appendLogString(stringToAppend: "==================================================")
                appendLogString(stringToAppend: "Please review the above information. If everything looks good, press the submit button. Otherwise, please verify the dropdowns and your CSV file and run another pre-flight check.")
                appendLogString(stringToAppend: "==================================================")
            } else {
                _ = popPrompt().generalWarning(question: "No CSV Path Found", text: "Please browse for a CSV file in order to continue.")
                return
            }
        } else {
            _ = popPrompt().generalWarning(question: "Please Verify Credentials", text: "Please enter your server URL, and the credentials for an administrator account, and then verify your credentials to continue.")
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
                    if self.popAttributeOutlet.titleOfSelectedItem != "macOS Static Group" && self.popAttributeOutlet.titleOfSelectedItem != "iOS Static Group" && self.popAttributeOutlet.titleOfSelectedItem != "User Static Group" {
                        self.myURL = xmlBuilder().createPUTURL(url: self.globalServerURL!, endpoint: self.globalEndpoint!, idType: self.globalEndpointID!, columnA: currentRow[0])
                    } else {
                        if self.popAttributeOutlet.titleOfSelectedItem == "macOS Static Group" {
                            self.myURL = xmlBuilder().createMacGroupURL(url: self.globalServerURL!, columnB: currentRow[1])
                        }
                        
                        if self.popAttributeOutlet.titleOfSelectedItem == "iOS Static Group" {
                            self.myURL = xmlBuilder().createiOSGroupURL(url: self.globalServerURL!, columnB: currentRow[1])
                        }
                        
                        if self.popAttributeOutlet.titleOfSelectedItem == "User Static Group" {
                            self.myURL = xmlBuilder().createUserGroupURL(url: self.globalServerURL!, columnB: currentRow[1])
                        }
                    }
                    
                } else {
                    self.myURL = xmlBuilder().createPOSTURL(url: self.globalServerURL!)
                }
                
                let encodedXML = xmlBuilder().createXML(popIdentifier: self.popIDOutlet.titleOfSelectedItem!, popDevice: self.popDeviceOutlet.titleOfSelectedItem!, popAttribute: self.popAttributeOutlet.titleOfSelectedItem!, eaID: self.txtEAID.stringValue, columnB: currentRow[1], columnA: currentRow[0])
                
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
                                self.printString(stringToPrint: "Device with \(self.globalEndpointID!) \(currentRow[0]) - ")
                                self.appendGreen(stringToPrint: "OK! - \(httpResponse.statusCode)")
                                // Update the progress bar
                                self.barProgress.doubleValue = Double(rowCounter)
                            }
                        } else {
                            // If that response is not a success response
                            DispatchQueue.main.async {
                                // Print information to the log box
                                self.printString(stringToPrint: "Device with \(self.globalEndpointID!) \(currentRow[0]) - ")
                                self.appendRed(stringToPrint: "Failed! - \(httpResponse.statusCode)!")
                                if httpResponse.statusCode == 404 {
                                    self.printLineBreak()
                                    self.appendLogString(stringToAppend: "HTTP 404 means 'not found'. There is no device with \(self.globalEndpointID!) \(currentRow[0]) enrolled in your JSS.")
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
            self.appendRed(stringToPrint:        "**************************************************************")
            self.appendLogString(stringToAppend: "               UPDATE RUN CANCELLED BY USER!")
            self.appendLogString(stringToAppend: "The request that has already been initiated will complete.")
            self.appendLogString(stringToAppend: "           All other requests have been cancelled.")
            self.appendRed(stringToPrint:        "**************************************************************")
            self.resetView()
            
        }
    }
    
    @IBAction func btnEnableDebug(_ sender: Any) {
        if globalDebug == "off" {
            globalDebug = "on"
        } else {
            globalDebug = "off"
        }
        self.appendLogString(stringToAppend: "Debug set to: " + self.globalDebug)
        self.printLineBreak()
    }
    
    
    // MARK: - Save Log Text
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
    
    // Prints red fixed point text with line break after - "FAIL"
    func appendRed(stringToPrint: String) {
        self.txtMain.textStorage?.append(NSAttributedString(string: "\(stringToPrint)\n", attributes: self.myFailFontAttribute))
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
    @IBAction func btnGiveThanks(_ sender: Any) {
        
    }
}
