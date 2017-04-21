//
//  ViewController.swift
//  The MUT
//
//  Created by Michael Levenick on 10/17/16.
//  Copyright © 2016 Levenick Enterprises LLC. All rights reserved.
//


// TODO: Fix the CSV Path Stuff (find file and parse)
// TODO: Fix the submit button to actually work
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
    var globalXMLSubsetStart: String!
    var globalXMLSubsetEnd: String!
    var globalXMLAttribute: String!
    var globalXMLExtraStart: String!
    var globalXMLExtraEnd: String!
    var globalXML: String!
    var globalEndpointID: String!
    var globalEAID: String!
    var concurrentRuns = 1
    var delimiter = ","
    var globalCSVContent: String!
    var globalParsedCSV: CSwiftV!
    var doneCounter = 0
    var base64Credentials: String!
    var serverURL: String!
    var verified = false
    var columnChecker = 0
    
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

    
    // MARK: - On load
    
    // Takes place right after view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Print welcome message
        txtMain.textStorage?.append(NSAttributedString(string: "Welcome to The MUT v3.0", attributes: myHeaderAttribute))
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
        
        // Set up concurrent runs
        if mainViewDefaults.value(forKey: "Concurrent") != nil {
            concurrentRuns = mainViewDefaults.value(forKey: "Concurrent")! as! Int
            appendLogString(stringToAppend: "Stored concurrent run value found: \(concurrentRuns)")
            printLineBreak()
        } else {
            appendLogString(stringToAppend: "No stored concurrent run value found. Using default value of 1. You can change this under Settings in the menu bar if you wish.")
            printLineBreak()
            delimiter = ","
        }
        
        // Set up the attribute outlet drop down
        popAttributeOutlet.removeAllItems()
        popAttributeOutlet.addItems(withTitles: [" Asset Tag"," Device Name"," Username"," Full Name"," Email"," Position"," Department"," Building"," Room"," Site by ID"," Site by Name"," Extension Attribute"])

    }
    
    override func viewWillAppear() {
        //resize the view
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 540, height: 628)
        
        //_ = xmlBuilder().generalUserUpdates(attributeType: "full_name", attributeValue: "Bobby Kammel")
    }
    
    // TODO: - Delete this function? I don't think it's needed
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    //Unique Identifier Dropdown to show pre-flight again
    @IBAction func popIdentifierAction(_ sender: Any) {
        notReadyToRun()
    }
    
    // Set up the dropdown items depending on what record type is selected
    @IBAction func popDeviceAction(_ sender: Any) {
        notReadyToRun()
        if popDeviceOutlet.titleOfSelectedItem == " Users" {
            popIDOutlet.removeAllItems()
            popIDOutlet.addItems(withTitles: [" Username"," ID Number"])
            popAttributeOutlet.removeAllItems()
            popAttributeOutlet.addItems(withTitles: [" User's Username"," User's Full Name"," Email Address"," User's Position"," Phone Number",/*" User's Site by ID"," User's Site by Name",*/" User Extension Attribute"]) // Removed sites for now, they appear to not be working
        }
        if popDeviceOutlet.titleOfSelectedItem == " iOS Devices" {
            popAttributeOutlet.removeAllItems()
            popAttributeOutlet.addItems(withTitles: [" Asset Tag"," Device Name"," Username"," Full Name"," Email"," Position"," Department"," Building"," Room",/*" Site by ID"," Site by Name",*/" Extension Attribute"]) // Removed Sites for now, they appear to not be working
            if popAttributeOutlet.titleOfSelectedItem == " Device Name" {
                popIDOutlet.removeAllItems()
                popIDOutlet.addItems(withTitles: [" Serial Number"])
            } else {
                popIDOutlet.removeAllItems()
                popIDOutlet.addItems(withTitles: [" Serial Number"," ID Number"])
            }
                    }
        if popDeviceOutlet.titleOfSelectedItem == " MacOS Devices" {
            popIDOutlet.removeAllItems()
            popIDOutlet.addItems(withTitles: [" Serial Number"," ID Number"])
            
            popAttributeOutlet.removeAllItems()
            popAttributeOutlet.addItems(withTitles: [" Asset Tag"," Device Name"," Username"," Full Name"," Email"," Position"," Department"," Building"," Room"," Site by ID"," Site by Name"," Extension Attribute"])
        }
    }
    
    @IBAction func popAttributeAction(_ sender: Any) {
        notReadyToRun()
        if popAttributeOutlet.titleOfSelectedItem == " Extension Attribute" || popAttributeOutlet.titleOfSelectedItem == " User Extension Attribute" {
            txtEAID.isEnabled = true
        } else {
            txtEAID.isEnabled = false
        }
        if popAttributeOutlet.titleOfSelectedItem == " Site by ID" {
            appendRed(stringToPrint: "To remove a device from all sites, assign a device to Site ID '-1'.")
            printLineBreak()
        }
        if popAttributeOutlet.titleOfSelectedItem == " Site by Name" {
            appendRed(stringToPrint: "To remove a device from all sites, assign a device to Site Name 'None'.")
            printLineBreak()
        }
        if popDeviceOutlet.titleOfSelectedItem == " iOS Devices" {
            if popAttributeOutlet.titleOfSelectedItem == " Device Name" {
                popIDOutlet.removeAllItems()
                popIDOutlet.addItems(withTitles: [" Serial Number"])
            } else {
                popIDOutlet.removeAllItems()
                popIDOutlet.addItems(withTitles: [" Serial Number"," ID Number"])
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
                //print(openPanel.URL!) //uncomment for debugging
                self.globalPathToCSV = openPanel.url! as NSURL!
                //print(self.globalPathToCSV.path!) //uncomment for debugging
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
            print(serverURL)
            
            btnAcceptOutlet.isHidden = true
            spinWheel.startAnimation(self)
            let concatCredentials = "\(txtUser.stringValue):\(txtPass.stringValue)"
            let utf8Credentials = concatCredentials.data(using: String.Encoding.utf8)
            base64Credentials = utf8Credentials?.base64EncodedString()
            
            if txtUser.stringValue != "" && txtPass.stringValue != "" {
                
                DispatchQueue.main.async {
                    //let myURL = "\(self.ApprovedURL!)activationcode"
                    let myURL = "\(self.serverURL!)activationcode"
                    let encodedURL = NSURL(string: myURL)
                    let request = NSMutableURLRequest(url: encodedURL! as URL)
                    request.httpMethod = "GET"
                    let configuration = URLSessionConfiguration.default
                    configuration.httpAdditionalHeaders = ["Authorization" : "Basic \(self.base64Credentials!)", "Content-Type" : "text/xml", "Accept" : "text/xml"]
                    let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
                    let task = session.dataTask(with: request as URLRequest, completionHandler: {
                        (data, response, error) -> Void in
                        if let httpResponse = response as? HTTPURLResponse {
                            //print(httpResponse.statusCode)
                            
                            if httpResponse.statusCode >= 199 && httpResponse.statusCode <= 299 {
                                //self.delegateCredentials?.userDidEnterCredentials(serverCredentials: self.base64Credentials) // Delegate for passing to main view
                                self.globalServerCredentials = self.base64Credentials
                                self.globalServerURL = self.serverURL
                                //self.printLineBreak()
                                self.appendLogString(stringToAppend: "Credentials Successfully Verified.")
                                self.printLineBreak()
                                self.verified = true
                                
                                // Store username if button pressed
                                if self.btnStoreUser.state == 1 {
                                    self.mainViewDefaults.set(self.txtUser.stringValue, forKey: "UserName")
                                    self.mainViewDefaults.synchronize()
                                    //self.delegateUsername?.userDidSaveUsername(savedUser: self.txtUser.stringValue)
                                } else {
                                    self.mainViewDefaults.removeObject(forKey: "UserName")
                                    self.mainViewDefaults.synchronize()
                                }
                                self.spinWheel.stopAnimation(self)
                                self.btnAcceptOutlet.isHidden = false
                                //self.dismissViewController(self)
                            } else {
                                DispatchQueue.main.async {
                                    self.spinWheel.stopAnimation(self)
                                    self.btnAcceptOutlet.isHidden = false
                                    _ = popPrompt().generalWarning(question: "Invalid Credentials", text: "The credentials you entered do not seem to have sufficient permissions. This could be due to an incorrect user/password, or possibly from insufficient permissions. MUT tests this against the user's ability to view the Activation Code via the API.")
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

    
    
    //vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    
    // MARK: - Delegate functions for passing data between view controllers
    
    // Pass back the Attribute information and CSV to be parsed
    //func userDidEnterAttributes(updateAttributes: Array<Any>) {
        
    func userDidEnterAttributes() {
        btnSubmitOutlet.isHidden = false
        //btnAttribute.image = NSImage(named: "NSStatusAvailable")
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
                globalXMLExtraStart = ""
                globalXMLExtraEnd = ""
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
                globalXMLExtraStart = ""
                globalXMLExtraEnd = ""
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
    func userDidEnterPath() {
        
        globalCSVPath = txtCSV.stringValue
        //printLineBreak()
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
    
    @IBAction func btnChangeConcurrent(_ sender: AnyObject) {
        
        let newConcurrent = popPrompt().selectConcurrent(question: "Change Concurrent Runs", text: "How many updates would you like to run concurrently? More will be faster, but will put a higher load on your server.")
        if newConcurrent == true {
            appendLogString(stringToAppend: "MUT will only run one (1) update at a time. This value will be stored to defaults.")
            printLineBreak()
            concurrentRuns = 1
            mainViewDefaults.set(concurrentRuns, forKey: "Concurrent")
        } else {
            appendLogString(stringToAppend: "MUT will run two (2) updates at a time. This value will be stored to defaults.")
            printLineBreak()
            concurrentRuns = 2
            mainViewDefaults.set(concurrentRuns, forKey: "Concurrent")
        }
    }
    
    
    //Pre Flight Checks
    @IBAction func btnPreFlight(_ sender: Any) {
        if verified {

            userDidEnterAttributes()
            
            if txtCSV.stringValue != "" {
                userDidEnterPath()
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
                 userDidEnterPath()
            } else {
                _ = popPrompt().generalWarning(question: "No CSV Path Found", text: "Please browse for a CSV file in order to continue.")
                return
            }
            
            userDidEnterAttributes()
            if globalDeviceType == " iOS Devices" && globalAttributeType == " Device Name" {
                enforceMobileNames()
            } else {
                putData()
            }
        } else {
            _ = popPrompt().generalWarning(question: "Please Verify Credentials", text: "Please enter your server URL, and the credentials for an administrator account, and then verify your credentials to continue.")
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
        }
        // Declare variables needed for progress tracking
        var rowCounter = 0
        let row = globalParsedCSV.rows // Send parsed rows to an array
        print(row)
        let lastrow = row.count - 1
        print("The last row will be \(lastrow)")
        var i = 0
        lblEndLine.stringValue = "\(row.count)"
        
        // Set the max concurrent ops to the selectable number
        myOpQueue.maxConcurrentOperationCount = concurrentRuns
        
        // Semaphore causes the op queue to wait for responses before sending a new request
        let semaphore = DispatchSemaphore(value: 0)
        

        while i <= lastrow {
            // Sets the current row to the row of the loop
            let currentRow = row[i]
            print(currentRow)
            print(self.globalServerURL)
            print(self.globalEndpoint)
            print(self.globalEndpointID)
            
            // Concatenate the URL from attribute page variables and CSV
            let myURL = "\(self.globalServerURL!)\(self.globalEndpoint!)/\(self.globalEndpointID!)/\(currentRow[0])"
            print(myURL)
            
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
            
            let encodedXML = xmlBuilder().enforceName(newName: currentRow[1], serialNumber: currentRow[0])
            //let encodedXML = returnedXML?.data(using: String.Encoding.utf8)
            
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
                        _ = popPrompt().generalWarning(question: "Fatal Error", text: "The MUT received a fatal error while uploading. \n\n \(error!.localizedDescription)")
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
    
    // MARK: - Cancel function
    // Allow cancelling the run early, and print verbose information if it happens
    @IBOutlet weak var btnCancelOutlet: NSButton!
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
}
