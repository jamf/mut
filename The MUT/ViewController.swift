//
//  ViewController.swift
//  The MUT
//
//  Created by Michael Levenick on 10/17/16.
//  Copyright © 2016 Levenick Enterprises LLC. All rights reserved.
//

import Cocoa
import Foundation

class ViewController: NSViewController, URLSessionDelegate, DataSentURL, DataSentCredentials, DataSentUsername, DataSentPath, DataSentAttributes {
    
    // MARK: - Declarations
    
    // Declare a bunch of global variables to use in various functions
    var globalServerURL: String!
    var globalServerCredentials: String!
    var globalCSVPath: String!
    var globalDeviceType: String!
    var globalIDType: String!
    var globalAttributeType: String!
    var globalEndpoint: String!
    var globalXMLDevice: String!
    var globalXMLSubsetStart: String!
    var globalXMLSubsetEnd: String!
    var globalXMLAttribute: String!
    var globalXMLExtraStart: String!
    var globalXMLExtraEnd: String!
    var globalXML: String!
    var globalEndpointID: String!
    var globalEAID: String!
    var concurrentRuns = 2
    var delimiter = ","
    var globalCSVContent: String!
    var globalParsedCSV: CSwiftV!
    var doneCounter = 0
    
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
    @IBOutlet weak var btnServer: NSButton!
    @IBOutlet weak var btnCredentials: NSButton!
    @IBOutlet weak var btnAttribute: NSButton!
    @IBOutlet weak var btnCancelOutlet: NSButton!
    @IBOutlet weak var btnSubmitOutlet: NSButton!
    @IBOutlet weak var btnSaveOutlet: NSButton!
    
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

    // Defining functions for writing/appending log information
    
    // Simple line break
    func printLineBreak() {
        self.txtMain.textStorage?.append(NSAttributedString(string: "\n", attributes: self.myFontAttribute))
    }
    
    // Prints fixed point text with no line break after
    func printString(stringToPrint: String) {
        self.txtMain.textStorage?.append(NSAttributedString(string: "\(stringToPrint)", attributes: self.myFontAttribute))
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
    
    // MARK: - On load
    
    // Takes place right after view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Print welcome message
        txtMain.textStorage?.append(NSAttributedString(string: "Welcome to The MUT v3.0", attributes: myHeaderAttribute))
        printLineBreak()
        printLineBreak()
        
        // Restore icons if they should be set (stored values are present)
        if mainViewDefaults.value(forKey: "ServerIcon") != nil && mainViewDefaults.value(forKey: "GlobalURL") != nil{
            let iconServer = mainViewDefaults.value(forKey: "ServerIcon") as! String
            globalServerURL = mainViewDefaults.value(forKey: "GlobalURL") as! String
            btnServer.image = NSImage(named: iconServer)
            btnCredentials.isEnabled = true
            printString(stringToPrint: "Stored URL: ")
            let cleanURL = globalServerURL.replacingOccurrences(of: "JSSResource/", with: "")
            appendLogString(stringToAppend: cleanURL)
        }
        
        // Restoring more values and icons depending on stored defaults
        if mainViewDefaults.value(forKey: "UserName") != nil {
            let iconCredentials = "NSStatusPartiallyAvailable"
            btnCredentials.image = NSImage(named: iconCredentials)
            printString(stringToPrint: "Stored Username: ")
            appendLogString(stringToAppend: mainViewDefaults.value(forKey: "UserName") as! String)
        }
    }
    
    override func viewWillAppear() {
        //resize the view
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 600, height: 400)
    }
    
    // UX hand holding pop ups
    override func viewDidAppear() {
        // Start here popup - points to Server
        if mainViewDefaults.value(forKey: "GlobalURL") == nil {
            performSegue(withIdentifier: "segueStartHere", sender: self)
        }
        // Re-enter password popup - points to credentials
        if mainViewDefaults.value(forKey: "UserName") != nil && mainViewDefaults.value(forKey: "didDisplayNoPass") == nil {
            performSegue(withIdentifier: "segueNoPass", sender: self)
            mainViewDefaults.set("true", forKey: "didDisplayNoPass")
        }
    }
    // TODO: - Delete this function? I don't think it's needed
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    // MARK: - Delegate functions for passing data between view controllers
    
    // User enters URL information on Server view
    func userDidEnterURL(serverURL: String) {
        globalServerURL = serverURL
        btnServer.image = NSImage(named: "NSStatusAvailable")
        mainViewDefaults.set(globalServerURL, forKey: "GlobalURL")
        mainViewDefaults.set("NSStatusAvailable", forKey: "ServerIcon")
        mainViewDefaults.synchronize()
        btnCredentials.isEnabled = true
        let cleanURL = globalServerURL.replacingOccurrences(of: "JSSResource/", with: "")
        appendLogString(stringToAppend: "URL: \(cleanURL)")
    }
    
    // Pass back the base 64 encoded credentials, or auth failure, from Credentials view
    func userDidEnterCredentials(serverCredentials: String) {
        if serverCredentials != "CREDENTIAL AUTHENTICATION FAILURE" {
            btnCredentials.image = NSImage(named: "NSStatusAvailable")
            btnAttribute.isEnabled = true
            globalServerCredentials = serverCredentials
            printLineBreak()
            appendLogString(stringToAppend: "Credentials Successfully Verified.")
            printLineBreak()
            //print("Main view has \(globalServerCredentials)")
        } else {
            btnCredentials.image = NSImage(named: "NSStatusUnavailable")
            printLineBreak()
            appendLogString(stringToAppend: "Authentication Failure! Go to the Credentials screen to retry.")
        }
    }
    
    // Pass back the Attribute information and CSV to be parsed
    func userDidEnterAttributes(updateAttributes: Array<Any>) {
        btnSubmitOutlet.isHidden = false
        btnAttribute.image = NSImage(named: "NSStatusAvailable")
        globalDeviceType = updateAttributes[0] as! String
        globalIDType = updateAttributes[1] as! String
        globalAttributeType = updateAttributes[2] as! String
        globalEAID = updateAttributes[3] as! String
        appendLogString(stringToAppend: "Device Type: \(globalDeviceType!)")
        appendLogString(stringToAppend: "ID Type: \(globalIDType!)")
        appendLogString(stringToAppend: "Attribute Type: \(globalAttributeType!)")
        
        // MARK: - XML Building variables
        
        // Switches to set XML and Endpoint values
        switch (globalDeviceType) {
            case " iOS Devices" :
                globalXMLDevice = "mobile_device"
                globalEndpoint = "mobiledevices"
                //print("iOS")
            case " MacOS Devices" :
                globalXMLDevice = "computer"
                globalEndpoint = "computers"
                //print("MacOS")
            case " Users" :
                globalXMLDevice = "user"
                globalEndpoint = "users"
                //print("MacOS")
            default:
                print("Something Broke")
        }
        
        // Switches to set Identifier type
        switch (globalIDType) {
            case " Serial Number" :
                globalEndpointID = "serialnumber"
                //print("Serial")
            case " ID Number" :
                globalEndpointID = "id"
                //print("ID")
            case " Username" :
                globalEndpointID = "name"
                //print("ID")
            default:
                print("Something Broke")
        }
        
        // Switches for attributes and subsets
        switch (globalAttributeType) {
        // iOS and MacOS
            case " Device Name" :
                if globalDeviceType == " iOS Devices" {
                    //print("GOING TO ENFORCE")
                    // TODO: Add name enforcement function
                }
                if globalDeviceType == " MacOS Devices"{
                    globalXMLSubsetStart = "<general>"
                    globalXMLSubsetEnd = "</general>"
                    globalXMLAttribute = "name"
                    globalXMLExtraStart = ""
                    globalXMLExtraEnd = ""
                    //print ("General Name")
                }
            case " Asset Tag" :
                globalXMLSubsetStart = "<general>"
                globalXMLSubsetEnd = "</general>"
                globalXMLAttribute = "asset_tag"
                globalXMLExtraStart = ""
                globalXMLExtraEnd = ""
                //print("General AssetTag")
            case " Username" :
                globalXMLSubsetStart = "<location>"
                globalXMLSubsetEnd = "</location>"
                globalXMLAttribute = "username"
                globalXMLExtraStart = ""
                globalXMLExtraEnd = ""
                //print("Location Username")
            case " Full Name" :
                globalXMLSubsetStart = "<location>"
                globalXMLSubsetEnd = "</location>"
                globalXMLAttribute = "real_name"
                //print("Location RealName")
            case " Email" :
                globalXMLSubsetStart = "<location>"
                globalXMLSubsetEnd = "</location>"
                globalXMLAttribute = "email_address"
                globalXMLExtraStart = ""
                globalXMLExtraEnd = ""
                //print("Location EmailAddress")
            case " Position" :
                globalXMLSubsetStart = "<location>"
                globalXMLSubsetEnd = "</location>"
                globalXMLAttribute = "position"
                //print("Location Position")
            case " Department" :
                globalXMLSubsetStart = "<location>"
                globalXMLSubsetEnd = "</location>"
                globalXMLAttribute = "department"
                globalXMLExtraStart = ""
                globalXMLExtraEnd = ""
                //print("Location Department")
            case " Building" :
                globalXMLSubsetStart = "<location>"
                globalXMLSubsetEnd = "</location>"
                globalXMLAttribute = "building"
                globalXMLExtraStart = ""
                globalXMLExtraEnd = ""
                //print("Location Building")
            case " Room" :
                globalXMLSubsetStart = "<location>"
                globalXMLSubsetEnd = "</location>"
                globalXMLAttribute = "room"
                globalXMLExtraStart = ""
                globalXMLExtraEnd = ""
                //print("Location Room")
            case " Site by ID" :
                globalXMLSubsetStart = "<general>"
                globalXMLSubsetEnd = "</general>"
                globalXMLAttribute = "site"
                globalXMLExtraStart = "<id>"
                globalXMLExtraEnd = "</id>"
                //print("Site by ID General")
            case " Site by Name" :
                globalXMLSubsetStart = "<general>"
                globalXMLSubsetEnd = "</general>"
                globalXMLAttribute = "site"
                globalXMLExtraStart = "<name>"
                globalXMLExtraEnd = "</name>"
                //print("Site by Name General")
            case " Extension Attribute" : // TODO: Add EA stuff and sites
                globalXMLSubsetStart = "<extension_attributes>"
                globalXMLSubsetEnd = "</extension_attributes>"
                globalXMLAttribute = "extension_attribute"
                globalXMLExtraStart = "<id>\(globalEAID!)</id><value>"
                globalXMLExtraEnd = "</value>"
            
        // Users
            case " User's Username" :
                globalXMLAttribute = "name"
                globalXMLSubsetStart = ""
                globalXMLSubsetEnd = ""
                globalXMLExtraStart = ""
                globalXMLExtraEnd = ""
                //print("Username")
            case " User's Full Name" :
                globalXMLAttribute = "full_name"
                globalXMLSubsetStart = ""
                globalXMLSubsetEnd = ""
                globalXMLExtraStart = ""
                globalXMLExtraEnd = ""
                //print("Full name")
            case " Email Address" :
                globalXMLAttribute = "email"
                globalXMLSubsetStart = ""
                globalXMLSubsetEnd = ""
                globalXMLExtraStart = ""
                globalXMLExtraEnd = ""
                //print("Email")
            case " User's Position" :
                globalXMLAttribute = "position"
                globalXMLSubsetStart = ""
                globalXMLSubsetEnd = ""
                globalXMLExtraStart = ""
                globalXMLExtraEnd = ""
                //print("Position")
            case " Phone Number" :
                globalXMLAttribute = "phone_number"
                globalXMLSubsetStart = ""
                globalXMLSubsetEnd = ""
                globalXMLExtraStart = ""
                globalXMLExtraEnd = ""
                //print("Phone Number")
            case " User's Site by ID" :
                globalXMLSubsetStart = "<sites>"
                globalXMLSubsetEnd = "</sites>"
                globalXMLAttribute = "site"
                globalXMLExtraStart = "<id>"
                globalXMLExtraEnd = "</id>"
                //print("Site by ID General")
            case " User's Site by Name" :
                globalXMLSubsetStart = "<sites>"
                globalXMLSubsetEnd = "</sites>"
                globalXMLAttribute = "site"
                globalXMLExtraStart = "<name>"
                globalXMLExtraEnd = "</name>"
                //print("Site by ID General") // TODO: Fix EA STuff and Sites
            case " User Extension Attribute" :
                globalXMLSubsetStart = "<extension_attributes>"
                globalXMLSubsetEnd = "</extension_attributes>"
                globalXMLAttribute = "extension_attribute"
                globalXMLExtraStart = "<id>\(globalEAID!)</id><value>"
                globalXMLExtraEnd = "</value>"
                //print("User EA")
            default:
                print("Something Broke")
        }
    }
    
    // Pass back the CSV Path
    func userDidEnterPath(csvPath: String) {
        
        // Set up delimiter
        if mainViewDefaults.value(forKey: "Delimiter") != nil {
            delimiter = mainViewDefaults.value(forKey: "Delimiter")! as! String
        }
        
        globalCSVPath = csvPath
        printLineBreak()
        appendLogString(stringToAppend: "CSV: \(globalCSVPath!)")
        
        // Parse the CSV into an array
        globalCSVContent = try! NSString(contentsOfFile: globalCSVPath, encoding: String.Encoding.utf8.rawValue) as String!
        globalParsedCSV = CSwiftV(with: globalCSVContent as String, separator: delimiter, headers: ["Device", "Attribute"])
        appendLogString(stringToAppend: "Found \(globalParsedCSV.rows.count) rows in the CSV.")
        printLineBreak()
        
        // Display a preview of row 1 if only 1 row, or row 2 otherwise (to not preview headers)
        if globalParsedCSV.rows.count > 1 {
            let line1 = globalParsedCSV.rows[1]
            if line1.count >= 2 {
                self.appendLogString(stringToAppend: "Example row from your CSV:")
                self.appendLogString(stringToAppend: "\(globalIDType!.replacingOccurrences(of: " ", with: "")): \(line1[0]), \(globalAttributeType!): \(line1[1])")
            } else {
                self.appendRed(stringToPrint: "Not enough columns were found in your CSV!!!")
                self.appendRed(stringToPrint: "You can set a custom delimiter under the gear icon if you wish.")
            }
        } else if globalParsedCSV.rows.count > 0 {
            let line1 = globalParsedCSV.rows[0]
            if line1.count >= 2 {
                self.appendLogString(stringToAppend: "Example row from your CSV:")
                self.appendLogString(stringToAppend: "\(globalIDType.replacingOccurrences(of: " ", with: "")): \(line1[0]), \(globalAttributeType!): \(line1[1])")
            } else {
                self.appendRed(stringToPrint: "Not enough columns were found in your CSV!!!")
                self.appendRed(stringToPrint: "You can set a custom delimiter under the gear icon if you wish.")
            }
        } else {
            appendRed(stringToPrint: "No rows found in your CSV!!!")
        }
        printLineBreak()
    }
    
    // Pass back the Username alone to store if selected
    func userDidSaveUsername(savedUser: String) {
        mainViewDefaults.set(savedUser, forKey: "UserName")
    }
    
    // Function for segue variable passing
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueServer" {
            let ServerView: ServerView = segue.destinationController as! ServerView
            ServerView.delegateURL = self
        }
        
        if segue.identifier == "segueCredentials" {
            let CredentialsView: CredentialsView = segue.destinationController as! CredentialsView
            CredentialsView.delegateCredentials = self
            CredentialsView.delegateUsername = self
            CredentialsView.representedObject = globalServerURL as String
        }
        
        if segue.identifier == "segueAttributes" {
            let AttributesView: AttributesView = segue.destinationController as! AttributesView
            AttributesView.delegatePath = self
            AttributesView.delegateAttributes = self
        }
    }
    
    @IBAction func btnClearStored(_ sender: AnyObject) {
        //Clear all stored values
        if let bundle = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundle)
        }
    }
    
    // Run enforce name function if proper attributes are selected
    // Otherwise, run put data function and update attributes
    @IBAction func submitRequests(_ sender: Any) {
        if globalDeviceType == " iOS Devices" && globalAttributeType == " Device Name" {
            enforceMobileNames()
        } else {
            putData()
        }
    }
    
    // MARK: - PUT DATA FUNCTION
    func putData() {
        
        if mainViewDefaults.value(forKey: "ConcurrentRows") != nil {
            concurrentRuns = Int(mainViewDefaults.value(forKey: "ConcurrentRows") as! String)!
        }
        
        // Async update the UI for the start of the run
        DispatchQueue.main.async {
            self.appendLogString(stringToAppend: "Beginning Update Run! Sending \(self.concurrentRuns) rows at a time.")
            self.printLineBreak()
            self.lblLine.isHidden = false
            self.lblCurrent.isHidden = false
            self.lblEndLine.isHidden = false
            self.lblOf.isHidden = false
            self.barProgress.isHidden = false
            self.barProgress.maxValue = Double(self.globalParsedCSV.rows.count)
            self.btnSubmitOutlet.isHidden = true
            self.btnCancelOutlet.isHidden = false
            self.btnSaveOutlet.isHidden = true
        }
        // Declare variables needed for progress tracking
        var rowCounter = 0
        let row = globalParsedCSV.rows // Send parsed rows to an array
        let lastrow = row.count - 1
        var i = 0
        lblEndLine.stringValue = "\(row.count)"
        
        // Set the max concurrent ops to the selectable number
        myOpQueue.maxConcurrentOperationCount = concurrentRuns
        
        // Semaphore causes the op queue to wait for responses before sending a new request
        let semaphore = DispatchSemaphore(value: 0)
        

        while i <= lastrow {
            // Sets the current row to the row of the loop
            let currentRow = row[i]
            
            // Concatenate the URL from attribute page variables and CSV
            let myURL = "\(self.globalServerURL!)\(self.globalEndpoint!)/\(self.globalEndpointID!)/\(currentRow[0])"
            
            // Concatenate the XML from attribute page variables and CSV, then encode it
            
            
                self.globalXML =    "<\(self.globalXMLDevice!)>" +
                                        "\(self.globalXMLSubsetStart!)" +
                                            "<\(self.globalXMLAttribute!)>" +
                                                "\(self.globalXMLExtraStart!)\(currentRow[1])\(self.globalXMLExtraEnd!)" +
                                            "</\(self.globalXMLAttribute!)>" +
                                        "\(self.globalXMLSubsetEnd!)" +
                                    "</\(self.globalXMLDevice!)>"
            //print(globalXML)
            let encodedXML = globalXML.data(using: String.Encoding.utf8)

            // Add a PUT request to the operation queue
            myOpQueue.addOperation {
                let urlwithPercentEscapes = myURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
                let encodedURL = NSURL(string: urlwithPercentEscapes!)
                let request = NSMutableURLRequest(url: encodedURL! as URL)
                request.httpMethod = "PUT"
                request.httpBody = encodedXML!
                let configuration = URLSessionConfiguration.default
                configuration.httpAdditionalHeaders = ["Authorization" : "Basic \(self.globalServerCredentials!)", "Content-Type" : "text/xml", "Accept" : "text/xml"]
                let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
                let task = session.dataTask(with: request as URLRequest, completionHandler: {
                    (data, response, error) -> Void in
                    
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
                        _ = self.dialogueWarning(question: "Fatal Error", text: "The MUT received a fatal error while uploading. \n\n \(error!.localizedDescription)")
                    }
                })
                // Send the request and then wait for the semaphore signal
                task.resume()
                semaphore.wait()
                
                // If we're on the last row sent, update the UI to reset for another run
                if rowCounter == lastrow {
                    DispatchQueue.main.async {
                        self.lblLine.isHidden = true
                        self.lblCurrent.isHidden = true
                        self.lblEndLine.isHidden = true
                        self.lblOf.isHidden = true
                        self.barProgress.isHidden = true
                        self.btnSubmitOutlet.isHidden = false
                        self.barProgress.doubleValue = 0.0
                        self.lblLine.stringValue = "0"
                        self.btnCancelOutlet.isHidden = true
                        self.btnSaveOutlet.isHidden = false
                    }
                }
            }
            i += 1
        }
    }
    
    // MARK: - Enforce Mobile Device Names
    func enforceMobileNames() {
        
        if mainViewDefaults.value(forKey: "ConcurrentRows") != nil {
            concurrentRuns = Int(mainViewDefaults.value(forKey: "ConcurrentRows") as! String)!
        }
        
        //print("ENFORCING NAMES!")
        // Async update the UI for the start of the run
        DispatchQueue.main.async {
            self.appendLogString(stringToAppend: "Beginning Update Run! Sending \(self.concurrentRuns) rows at a time.")
            self.printLineBreak()
            self.lblLine.isHidden = false
            self.lblCurrent.isHidden = false
            self.lblEndLine.isHidden = false
            self.lblOf.isHidden = false
            self.barProgress.isHidden = false
            self.barProgress.maxValue = Double(self.globalParsedCSV.rows.count)
            self.btnSubmitOutlet.isHidden = true
            self.btnCancelOutlet.isHidden = false
            self.btnSaveOutlet.isHidden = true
        }
        // Declare variables needed for progress tracking
        var rowCounter = 0
        let row = globalParsedCSV.rows // Send parsed rows to an array
        let lastrow = row.count - 1
        var i = 0
        lblEndLine.stringValue = "\(row.count)"
        
        // Set the max concurrent ops to the selectable number
        myOpQueue.maxConcurrentOperationCount = concurrentRuns
        
        // Semaphore causes the op queue to wait for responses before sending a new request
        let semaphore = DispatchSemaphore(value: 0)
        
        
        while i <= lastrow {
            // Sets the current row to the row of the loop
            let currentRow = row[i]
            
            // Concatenate the URL from attribute page variables and CSV
            let myURL = "\(self.globalServerURL!)mobiledevicecommands/command/DeviceName"
            //print(myURL)
            // Concatenate the XML from attribute page variables and CSV, then encode it
            
            
            self.globalXML =    "<mobile_device_command>" +
                                    "<command>DeviceName</command>" +
                                    "<device_name>\(currentRow[1])</device_name>" +
                                    "<mobile_devices>" +
                                        "<mobile_device>" +
                                            "<serial_number>\(currentRow[0])</serial_number>" +
                                        "</mobile_device>" +
                                    "</mobile_devices>" +
                                "</mobile_device_command>"
            let encodedXML = globalXML.data(using: String.Encoding.utf8)
            
            // Add a POST request to the operation queue
            myOpQueue.addOperation {
                let urlwithPercentEscapes = myURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
                let encodedURL = NSURL(string: urlwithPercentEscapes!)
                let request = NSMutableURLRequest(url: encodedURL! as URL)
                request.httpMethod = "POST"
                request.httpBody = encodedXML!
                let configuration = URLSessionConfiguration.default
                configuration.httpAdditionalHeaders = ["Authorization" : "Basic \(self.globalServerCredentials!)", "Content-Type" : "text/xml", "Accept" : "text/xml"]
                let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
                let task = session.dataTask(with: request as URLRequest, completionHandler: {
                    (data, response, error) -> Void in
                    
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
                        _ = self.dialogueWarning(question: "Fatal Error", text: "The MUT received a fatal error while uploading. \n\n \(error!.localizedDescription)")
                    }
                })
                // Send the request and then wait for the semaphore signal
                task.resume()
                semaphore.wait()
                
                // If we're on the last row sent, update the UI to reset for another run
                if rowCounter == lastrow {
                    DispatchQueue.main.async {
                        self.lblLine.isHidden = true
                        self.lblCurrent.isHidden = true
                        self.lblEndLine.isHidden = true
                        self.lblOf.isHidden = true
                        self.barProgress.isHidden = true
                        self.btnSubmitOutlet.isHidden = false
                        self.barProgress.doubleValue = 0.0
                        self.lblLine.stringValue = "0"
                        self.btnCancelOutlet.isHidden = true
                        self.btnSaveOutlet.isHidden = false
                    }
                }
            }
            i += 1
        }
    }
    
    // MARK: - Cancel function
    // Allow cancelling the run early, and print verbose information if it happens
    @IBOutlet weak var btnCancel: NSButton!
    @IBAction func btnCancel(_ sender: Any) {
        myOpQueue.cancelAllOperations()
        DispatchQueue.main.async {
            self.appendRed(stringToPrint:        "**************************************************************")
            self.appendLogString(stringToAppend: "               UPDATE RUN CANCELLED BY USER!")
            self.appendLogString(stringToAppend: "The \(self.concurrentRuns) Requests that have already been initiated will complete.")
            self.appendLogString(stringToAppend: "           All other requests have been cancelled.")
            self.appendRed(stringToPrint:        "**************************************************************")
            self.lblLine.isHidden = true
            self.lblCurrent.isHidden = true
            self.lblEndLine.isHidden = true
            self.lblOf.isHidden = true
            self.barProgress.isHidden = true
            self.btnSubmitOutlet.isHidden = false
            self.barProgress.doubleValue = 0.0
            self.lblLine.stringValue = "0"
            self.btnCancelOutlet.isHidden = true
            self.btnSaveOutlet.isHidden = false
        }
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
                    /* error handling here */
                }

            }
        }
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        
    }
    func dialogueWarning (question: String, text: String) -> Bool {
        
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlertStyle.warning
        myPopup.addButton(withTitle: "OK")
        return myPopup.runModal() == NSAlertFirstButtonReturn
    }
}
