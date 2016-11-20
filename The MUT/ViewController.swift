//
//  ViewController.swift
//  The MUT
//
//  Created by Michael Levenick on 10/17/16.
//  Copyright © 2016 Levenick Enterprises LLC. All rights reserved.
//

import Cocoa
import Foundation

class ViewController: NSViewController, DataSentURL, DataSentCredentials, DataSentUsername, DataSentPath, DataSentAttributes {
    
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
    var globalXMLSubset: String!
    var globalXMLAttribute: String!
    var globalXMLExtraStart: String!
    var globalXMLExtraEnd: String!
    var globalEndpointID: String!
    var concurrentRuns = 3
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
        appendLogString(stringToAppend: "Device Type: \(globalDeviceType!)")
        appendLogString(stringToAppend: "ID Type: \(globalIDType!)")
        appendLogString(stringToAppend: "Attribute Type: \(globalAttributeType!)")
        
        // MARK: - XML Building variables
        
        // Switches to set XML and Endpoint values
        switch (globalDeviceType) {
            case " iOS Devices" :
                globalXMLDevice = "mobile_device"
                globalEndpoint = "mobiledevices"
                print("iOS")
            case " MacOS Devices" :
                globalXMLDevice = "computer"
                globalEndpoint = "computers"
                print("MacOS")
            case " Users" :
                globalXMLDevice = "user"
                globalEndpoint = "users"
                print("MacOS")
            default:
                print("Something Broke")
        }
        
        // Switches to set Identifier type
        switch (globalIDType) {
            case " Serial Number" :
                globalEndpointID = "serialnumber"
                print("Serial")
            case " ID Number" :
                globalEndpointID = "id"
                print("ID")
            case " Username" :
                globalEndpointID = "name"
                print("ID")
            default:
                print("Something Broke")
        }
        
        // Switches for attributes and subsets
        switch (globalAttributeType) {
        // iOS and MacOS
            case " Device Name" :
                if globalDeviceType == " iOS Devices" {
                    // TODO: Add name enforcement function
                }
                if globalDeviceType == " MacOS Devices"{
                    globalXMLSubset = "general"
                    globalXMLAttribute = "name"
                    print ("General Name")
                }
            case " Asset Tag" :
                globalXMLSubset = "general"
                globalXMLAttribute = "asset_tag"
                print("General AssetTag")
            case " Username" :
                globalXMLSubset = "location"
                globalXMLAttribute = "username"
                print("Location Username")
            case " Full Name" :
                globalXMLSubset = "location"
                globalXMLAttribute = "real_name"
                print("Location RealName")
            case " Email" :
                globalXMLSubset = "location"
                globalXMLAttribute = "email_address"
                print("Location EmailAddress")
            case " Position" :
                globalXMLSubset = "location"
                globalXMLAttribute = "position"
                print("Location Position")
            case " Department" :
                globalXMLSubset = "location"
                globalXMLAttribute = "department"
                print("Location Department")
            case " Building" :
                globalXMLSubset = "location"
                globalXMLAttribute = "building"
                print("Location Building")
            case " Room" :
                globalXMLSubset = "location"
                globalXMLAttribute = "room"
                print("Location Room")
            case " Site by ID" :
                globalXMLSubset = "general"
                globalXMLAttribute = "site"
                print("Site by ID General")
            case " Site by Name" :
                globalXMLSubset = "general"
                globalXMLAttribute = "site"
                print("Site by Name General")
            case " Extension Attribute" : // TODO: Add EA stuff
                globalEndpointID = "serialnumber"
                print("Serial")
            
        // Users
            case " User's Username" :
                globalXMLSubset = "general"
                globalXMLAttribute = "site"
                print("Site by ID General")
            case " User's Full Name" :
                globalXMLSubset = "general"
                globalXMLAttribute = "site"
                print("Site by ID General")
            case " Email Address" :
                globalXMLSubset = "general"
                globalXMLAttribute = "site"
                print("Site by ID General")
            case " User's Position" :
                globalXMLSubset = "general"
                globalXMLAttribute = "site"
                print("Site by ID General")
            case " Phone Number" :
                globalXMLSubset = "general"
                globalXMLAttribute = "site"
                print("Site by ID General")
            case " User's Site by ID" :
                globalXMLSubset = "general"
                globalXMLAttribute = "site"
                print("Site by ID General")
            case " User's Site by Name" :
                globalXMLSubset = "general"
                globalXMLAttribute = "site"
                print("Site by ID General")
            case " User Extension Attribute" :
                globalXMLSubset = "general"
                globalXMLAttribute = "site"
                print("Site by ID General")
            default:
                print("Something Broke")
        }
    }
    
    // Pass back the CSV Path
    func userDidEnterPath(csvPath: String) {
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
                self.appendLogString(stringToAppend: "\(globalIDType!.replacingOccurrences(of: " ", with: "")): \(line1[0]), \(globalAttributeType.replacingOccurrences(of: " ", with: "")): \(line1[1])")
            } else {
                self.appendRed(stringToPrint: "Not enough columns in your CSV!!!")
            }
        } else if globalParsedCSV.rows.count > 0 {
            let line1 = globalParsedCSV.rows[0]
            if line1.count >= 2 {
                self.appendLogString(stringToAppend: "Example row from your CSV:")
                self.appendLogString(stringToAppend: "\(globalIDType.replacingOccurrences(of: " ", with: "")): \(line1[0]), \(globalAttributeType.replacingOccurrences(of: " ", with: "")): \(line1[1])")
            } else {
                self.appendRed(stringToPrint: "Not enough columns in your CSV!!!")
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
        putData()
    }
    
    // MARK: - PUT DATA FUNCTION
    func putData() {
        // Async update the UI for the start of the run
        DispatchQueue.main.async {
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
            let xml =   "<\(self.globalXMLDevice!)>" +
                            "<\(self.globalXMLSubset!)>" +
                                "<\(self.globalXMLAttribute!)>\(currentRow[1])</\(self.globalXMLAttribute!)>" +
                            "</\(self.globalXMLSubset!)>" +
                        "</\(self.globalXMLDevice!)>"
            let encodedXML = xml.data(using: String.Encoding.utf8)

            // Add a PUT request to the operation queue
            myOpQueue.addOperation {
                let encodedURL = NSURL(string: myURL)
                let request = NSMutableURLRequest(url: encodedURL! as URL)
                request.httpMethod = "PUT"
                request.httpBody = encodedXML!
                let configuration = URLSessionConfiguration.default
                configuration.httpAdditionalHeaders = ["Authorization" : "Basic \(self.globalServerCredentials!)", "Content-Type" : "text/xml", "Accept" : "text/xml"]
                let session = Foundation.URLSession(configuration: configuration)
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
                        NSLog(error! as! String)
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
                    }
                }
            }
            i += 1
        }
    }
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
        }
    }
}
