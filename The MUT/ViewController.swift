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
    let myOpQueue = OperationQueue()
    var doneCounter = 0
    
    let mainViewDefaults = UserDefaults.standard
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

    
    // Declare outlets for Buttons
    @IBOutlet weak var btnServer: NSButton!
    @IBOutlet weak var btnCredentials: NSButton!
    @IBOutlet weak var btnAttribute: NSButton!
    @IBOutlet var MainViewController: NSView!

    @IBOutlet var txtMain: NSTextView!
    
    @IBOutlet weak var txtMainWrapper: NSScrollView!
    

    //Submit button and Spinner
    @IBOutlet weak var btnSubmitOutlet: NSButton!
    @IBOutlet weak var barProgress: NSProgressIndicator!
    @IBOutlet weak var spinProgress: NSProgressIndicator!
    @IBOutlet weak var btnCancelOutlet: NSButton!
    
    //Progress Labels
    @IBOutlet weak var lblCurrent: NSTextField!
    @IBOutlet weak var lblOf: NSTextField!
    @IBOutlet weak var lblEndLine: NSTextField!
    @IBOutlet weak var lblLine: NSTextField!

    // Takes place right after view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        txtMain.textStorage?.append(NSAttributedString(string: "Welcome to The MUT v3.0", attributes: myHeaderAttribute))
        printLineBreak()
        printLineBreak()
        
        // Restore icons if they are not null
        if mainViewDefaults.value(forKey: "ServerIcon") != nil && mainViewDefaults.value(forKey: "GlobalURL") != nil{
            let iconServer = mainViewDefaults.value(forKey: "ServerIcon") as! String
            globalServerURL = mainViewDefaults.value(forKey: "GlobalURL") as! String
            btnServer.image = NSImage(named: iconServer)
            btnCredentials.isEnabled = true
            printString(stringToPrint: "Stored URL: ")
            let cleanURL = globalServerURL.replacingOccurrences(of: "JSSResource/", with: "")
            appendLogString(stringToAppend: cleanURL)
        }
        
        if mainViewDefaults.value(forKey: "UserName") != nil {
            let iconCredentials = "NSStatusPartiallyAvailable"
            btnCredentials.image = NSImage(named: iconCredentials)
            printString(stringToPrint: "Stored Username: ")
            appendLogString(stringToAppend: mainViewDefaults.value(forKey: "UserName") as! String)
        }
        
    }
    
    func printLineBreak() {
        self.txtMain.textStorage?.append(NSAttributedString(string: "\n", attributes: self.myFontAttribute))
    }
    func printString(stringToPrint: String) {
        self.txtMain.textStorage?.append(NSAttributedString(string: "\(stringToPrint)", attributes: self.myFontAttribute))
    }
    func appendGreen(stringToPrint: String) {
        self.txtMain.textStorage?.append(NSAttributedString(string: "\(stringToPrint)\n", attributes: self.myOKFontAttribute))
        self.txtMain.scrollToEndOfDocument(self)
    }
    func appendRed(stringToPrint: String) {
        self.txtMain.textStorage?.append(NSAttributedString(string: "\(stringToPrint)\n", attributes: self.myFailFontAttribute))
        self.txtMain.scrollToEndOfDocument(self)
    }
    func appendLogString(stringToAppend: String) {
        self.txtMain.textStorage?.append(NSAttributedString(string: "\(stringToAppend)\n", attributes: self.myFontAttribute))
        self.txtMain.scrollToEndOfDocument(self)
    }
    func clearLog() {
        self.txtMain.textStorage?.setAttributedString(NSAttributedString(string: "", attributes: self.myFontAttribute))
    }
    
    override func viewWillAppear() {
        //resize the view
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 600, height: 400)
        
        
    }
    
    override func viewDidAppear() {
        if mainViewDefaults.value(forKey: "GlobalURL") == nil {
            performSegue(withIdentifier: "segueStartHere", sender: self)
            
        }
        if mainViewDefaults.value(forKey: "UserName") != nil && mainViewDefaults.value(forKey: "didDisplayNoPass") == nil {
            performSegue(withIdentifier: "segueNoPass", sender: self)
            mainViewDefaults.set("true", forKey: "didDisplayNoPass")
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


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
    
    // Pass back the base 64 encoded credentials, or auth failure
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
    
    // Pass back the Attribute information
    func userDidEnterAttributes(updateAttributes: Array<Any>) {
        btnSubmitOutlet.isHidden = false
        btnAttribute.image = NSImage(named: "NSStatusAvailable")
        globalDeviceType = updateAttributes[0] as! String
        globalIDType = updateAttributes[1] as! String
        globalAttributeType = updateAttributes[2] as! String
        appendLogString(stringToAppend: "Device Type: \(globalDeviceType!)")
        appendLogString(stringToAppend: "ID Type: \(globalIDType!)")
        appendLogString(stringToAppend: "Attribute Type: \(globalAttributeType!)")

        
        //printLineBreak()
        
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
            case " Extension Attribute" :
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
        globalCSVContent = try! NSString(contentsOfFile: globalCSVPath, encoding: String.Encoding.utf8.rawValue) as String!
        globalParsedCSV = CSwiftV(with: globalCSVContent as String, separator: delimiter, headers: ["Device", "Attribute"])
        appendLogString(stringToAppend: "Found \(globalParsedCSV.rows.count) rows in the CSV.")
        printLineBreak()
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

    @IBAction func btnClearText(_ sender: Any) {
        clearLog()
    }
    

    @IBAction func submitRequests(_ sender: Any) {
        putData()
    }
    

    func putData() {
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
        var rowCounter = 0

        let row = globalParsedCSV.rows
        let lastrow = row.count - 1
        lblEndLine.stringValue = "\(row.count)"

        myOpQueue.maxConcurrentOperationCount = concurrentRuns
        let semaphore = DispatchSemaphore(value: 0)
        var i = 0
        while i <= lastrow {

            let currentRow = row[i]
            let myURL = "\(self.globalServerURL!)\(self.globalEndpoint!)/\(self.globalEndpointID!)/\(currentRow[0])"
            let xml = "<\(self.globalXMLDevice!)><\(self.globalXMLSubset!)><\(self.globalXMLAttribute!)>\(currentRow[1])</\(self.globalXMLAttribute!)></\(self.globalXMLSubset!)></\(self.globalXMLDevice!)>"
            let encodedXML = xml.data(using: String.Encoding.utf8)

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
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode >= 199 && httpResponse.statusCode <= 299 {
                            DispatchQueue.main.async {
                                self.printString(stringToPrint: "Device with \(self.globalEndpointID!) \(currentRow[0]) - ")
                                self.appendGreen(stringToPrint: "OK! - \(httpResponse.statusCode)")
                                self.barProgress.doubleValue = Double(rowCounter)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.printString(stringToPrint: "Device with \(self.globalEndpointID!) \(currentRow[0]) - ")
                                self.appendRed(stringToPrint: "Failed! - \(httpResponse.statusCode)!")
                                self.barProgress.doubleValue = Double(rowCounter)
                            }
                        }
                        rowCounter += 1
                        semaphore.signal()
                        DispatchQueue.main.async {
                            self.lblLine.stringValue = "\(rowCounter)"
                        }
                        
                    }
                    if error != nil {
                        NSLog(error! as! String)
                    }
                })
                
                task.resume()
                semaphore.wait()
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
        DispatchQueue.main.async {


        }
    }
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
