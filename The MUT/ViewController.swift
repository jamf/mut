//
//  ViewController.swift
//  The MUT
//
//  Created by Michael Levenick on 10/17/16.
//  Copyright © 2016 Levenick Enterprises LLC. All rights reserved.
//

import Cocoa
import Alamofire
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

    
    // Declare outlets for Buttons
    @IBOutlet weak var btnServer: NSButton!
    @IBOutlet weak var btnCredentials: NSButton!
    @IBOutlet weak var btnAttribute: NSButton!
    @IBOutlet var MainViewController: NSView!

    @IBOutlet var txtMain: NSTextView!
    
    @IBOutlet weak var txtMainWrapper: NSScrollView!
    
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
        } else {
            btnCredentials.image = NSImage(named: "NSStatusUnavailable")
            printLineBreak()
            appendLogString(stringToAppend: "Authentication Failure! Go to the Credentials screen to retry.")
        }
    }
    
    // Pass back the Attribute information
    func userDidEnterAttributes(updateAttributes: Array<Any>) {
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
    
    @IBAction func printInfo(_ sender: AnyObject) {
        /*var id = 560
        let endid = 580
        while id <= endid {
            let fullRequestURL = globalServerURL + "computers/id/\(id)"
            let encodedURL = NSURL(string: fullRequestURL)
            let xml = "<computer><general><name>New Swif</name></general></computer>"
            let encodedXML = xml.data(using: String.Encoding.utf8)
            var request = URLRequest(url: encodedURL as! URL)
            request.httpMethod = "PUT"
            request.addValue("application/xml", forHTTPHeaderField: "Content-Type")
            request.addValue("Basic \(globalServerCredentials!)", forHTTPHeaderField: "Authorization")
            
            request.httpBody = encodedXML
            
            Alamofire.request(request).responseString { response in
                print ("Response String: \(response.response!.statusCode)")
                print ("URL: \(response.request!.url!)")
                self.txtNewMain.textStorage?.append(NSAttributedString(string: "\nURL: \(response.request!.url!)", attributes: self.myFontAttribute))
                self.txtNewMain.textStorage?.append(NSAttributedString(string: "\nResponse Code: \(response.response!.statusCode)", attributes: self.myFontAttribute))
                self.txtNewMain.scrollToEndOfDocument(self)
            }
            id = id + 1
        }
        */
//      let path = globalCSVPath
        let importer = CSVImporter<[String]>(path: globalCSVPath)
        importer.startImportingRecords { $0 }.onFinish { importedRecords in
            for record in importedRecords {
                
                let fullRequestURL = self.globalServerURL + "\(self.globalEndpoint!)/\(self.globalEndpointID!)/\(record[0])"
                let encodedURL = NSURL(string: fullRequestURL)
                let xml = "<\(self.globalXMLDevice!)><\(self.globalXMLSubset!)><\(self.globalXMLAttribute!)>\(record[1])</\(self.globalXMLAttribute!)></\(self.globalXMLSubset!)></\(self.globalXMLDevice!)>"
                let encodedXML = xml.data(using: String.Encoding.utf8)

                var request = URLRequest(url: encodedURL as! URL)
                request.httpMethod = "PUT"
                request.addValue("application/xml", forHTTPHeaderField: "Content-Type")
                request.addValue("Basic \(self.globalServerCredentials!)", forHTTPHeaderField: "Authorization")
                
                request.httpBody = encodedXML
                
                Alamofire.request(request).responseString { response in
                    self.appendLogString(stringToAppend: "URL: \(response.request!.url!)")
                    self.appendLogString(stringToAppend: "Response Code: \(response.response!.statusCode)")
                    self.printLineBreak()
                }

            }
        }
    }
    @IBAction func btnClearText(_ sender: Any) {
        clearLog()
    }
}
