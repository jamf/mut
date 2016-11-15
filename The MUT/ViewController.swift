//
//  ViewController.swift
//  The MUT
//
//  Created by Michael Levenick on 10/17/16.
//  Copyright © 2016 Levenick Enterprises LLC. All rights reserved.
//

import Cocoa
import CSVImporter

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
    
    @IBOutlet weak var lblLine: NSTextField!
    
    @IBOutlet weak var barProgress: NSProgressIndicator!
    
    @IBOutlet weak var btnSubmitOutlet: NSButton!
    @IBOutlet weak var lblCurrent: NSTextField!

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
        appendLogString(stringToAppend: "CSV: \(globalCSVPath!)")
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
        // Clear all stored values
        if let bundle = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundle)
        }
    }
    
    @IBAction func submitRequests(_ sender: AnyObject) {
        
        let backgroundQueue = OperationQueue()
        lblCurrent.isHidden = false
        lblLine.isHidden = false
        var counter = 0
        backgroundQueue.maxConcurrentOperationCount = 1
        btnSubmitOutlet.isHidden = true
        barProgress.startAnimation(self)
        let importer = CSVImporter<[String]>(path: globalCSVPath)
        importer.startImportingRecords { $0 }.onFinish { importedRecords in
            for record in importedRecords {
                
                //backgroundQueue.addOperation {
                    counter += 1
                    self.lblLine.stringValue = "\(counter)"
                    //self.lblLine.stringValue = record[0]
                    //self.txtMain.textStorage?.append(NSAttributedString(string: "\(record[0])\n", attributes: self.myFontAttribute))
                    let endpoint = "\(self.globalEndpoint!)/\(self.globalEndpointID!)/\(record[0])"
                    let client = JSSClient(urlString: self.globalServerURL!, allowUntrusted: true)
                    let xml = "<\(self.globalXMLDevice!)><\(self.globalXMLSubset!)><\(self.globalXMLAttribute!)>\(record[1])</\(self.globalXMLAttribute!)></\(self.globalXMLSubset!)></\(self.globalXMLDevice!)>"
                    let encodedXML = xml.data(using: String.Encoding.utf8)
                    
                    let response = client.sendRequestAndWait(endpoint: endpoint, method: .put, base64credentials: self.globalServerCredentials!, dataType: .xml, body: encodedXML)
                    
                    switch response {
                    case .badRequest:
                        self.appendLogString(stringToAppend: "Device with \(self.globalEndpointID!) \(record[0]) does not like the request.")
                        
                    case .error(let error):
                        self.appendLogString(stringToAppend: "Device with \(self.globalEndpointID!) \(record[0]) threw \(error)")
                        
                    case .httpCode(let code):
                        self.printString(stringToPrint: "Device with \(self.globalEndpointID!) \(record[0]) - ")
                        self.appendRed(stringToPrint: "Failed with code \(code)!")
                        
                    case .json:
                        self.appendLogString(stringToAppend: "Device with \(self.globalEndpointID!) \(record[0]) returned JSON??")
                        
                    case .success:
                        self.printString(stringToPrint: "Device with \(self.globalEndpointID!) \(record[0]) - ")
                        self.appendGreen(stringToPrint: "OK!")
                        
                    case .xml:
                        self.printString(stringToPrint: "Device with \(self.globalEndpointID!) \(record[0]) - ")
                        self.appendGreen(stringToPrint: "OK!")
                    }

              //  }
                
            }
            self.barProgress.stopAnimation(self)
            self.btnSubmitOutlet.isHidden = false
        }
        //barProgress.stopAnimation(self)
    }
    @IBAction func btnClearText(_ sender: Any) {
        clearLog()
    }

    @IBAction func btnAllow(_ sender: Any) {
        let client = JSSClient(urlString: globalServerURL!, allowUntrusted: true)
        let xmlbody = "<computer><general><name>SYNC BABY YEAH</name></general></computer>"
        let encodedXML = xmlbody.data(using: String.Encoding.utf8)
        var id = 560
        let endid = 580
        while id <= endid {
            let response = client.sendRequestAndWait(endpoint: "computers/id/\(id)", method: .put, base64credentials: globalServerCredentials!, dataType: .xml, body: encodedXML)
            print("Response recieved")
            
            switch response {
            case .badRequest:
                print("Bad request")
            case .error(let error):
                print("Receieved error:\n\(error)")
            case .httpCode(let code):
                print("Request failed with http status code \(code)")
            case .json(let json):
                print("Received JSON response:\n\(json)")
            case .success:
                print("Success with empty response")
            case .xml(let xml):
                print("Received XML response:\n\(xml.xmlString(withOptions: Int(XMLNode.Options.nodePrettyPrint.rawValue)))")
            }
            
            print("Completed \(id)")
            
            id = id + 1
        }

    }
}
