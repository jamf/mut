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
import SwiftyJSON

class ViewController: NSViewController, URLSessionDelegate, NSTableViewDelegate, DataSentDelegate {

    // Outlet of tab view to determine which tab is active
    @IBOutlet weak var tabViewOutlet: NSTabView!

    // Declare outlets for Buttons to change color and hide/show
    @IBOutlet weak var btnSubmitOutlet: NSButton!
    @IBOutlet weak var btnPreFlightOutlet: NSButton!
    
    // Declare outlet for entire controller
    @IBOutlet var MainViewController: NSView!
    
    //MARK: TableView Outlets and actions
    //tableMain
    @IBOutlet weak var tableMain: NSTableView!
    //Identifier Table
    @IBOutlet weak var tblIdentifier: NSTableView!
    @IBOutlet weak var lblRecordType: NSTextField!
    
    //Scopes Table
    @IBOutlet weak var tblScopes: NSTableView!
    @IBOutlet weak var lblScopeType: NSTextField!
    
    
    
    //@IBOutlet weak var identifierHeader: NSTableHeaderView!
    //@IBOutlet weak var identifierText: NSTextField!

    // Progress bar and labels for runtime
    @IBOutlet weak var barProgress: NSProgressIndicator!
    @IBOutlet weak var lblCurrent: NSTextField!
    @IBOutlet weak var lblOf: NSTextField!
    @IBOutlet weak var lblEndLine: NSTextField!
    @IBOutlet weak var lblLine: NSTextField!
    
    @IBOutlet weak var lblStatus: NSTextField!
    
    // DropDowns for Attributes etc
    @IBOutlet weak var txtCSV: NSTextField!
    @IBOutlet weak var popRecordTypeOutlet: NSPopUpButton!
    @IBOutlet weak var popActionTypeOutlet: NSPopUpButton!
    @IBOutlet weak var txtPrestageID: NSTextField!
    
    var globalPathToCSV: NSURL!
    var globalToken: String!
    var globalURL: String!
    var globalExpiry: Int!
    var globalBase64: String!
    var globalEndpoint: String!
    //Added globalTab to contain all the scope tab endpoints for table drawing
    var globalTab: String!
    var xmlToPut: Data!
    var jsonToSubmit: Data!
    var globalDelimiter: UnicodeScalar!
    var csvArray = [[String]]()
    
    func userDidAuthenticate(base64Credentials: String, url: String, token: String, expiry: Int) {
        globalExpiry = expiry
        globalToken = token
        print("Token is: \(token)")
        globalURL = url
        globalBase64 = base64Credentials
        preferredContentSize = NSSize(width: 550, height: 443)
    }
    
    let dataPrep = dataPreparation()
    let tokenMan = tokenManagement()
    let xmlMan = xmlManager()
    let CSVMan = CSVManipulation()
    let APIFunc = APIFunctions()
    let popMan = popPrompt()
    let jsonMan = jsonManager()
    
    
    //Variables used by tableViews
    var currentData : [[String: String]] = []
    var csvData : [[ String : String ]] = []
    var csvIdentifierData: [[String: String]] = []
    var scopeData: [[String: String]] = []

    
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
        preferredContentSize = NSSize(width: 550, height: 443)
        performSegue(withIdentifier: "segueLogin", sender: self)
        globalDelimiter = ","
    }
    
    
    //btnIdentifier reloads tableMain based on the index of the selected row in Identifier table
    @IBAction func btnIdentifier(_ sender: Any) {
        currentData = csvData
        let selectedIndex = tblIdentifier.clickedRow + 1
        //print("Selected Index is... \(selectedIndex)")
        let maxIndex = csvArray.count
        if selectedIndex == 0 {
            print("selectedIndex is 0, not redrawing...")
        } else if
            selectedIndex < maxIndex {
            csvData = dataPrep.buildDict(rowToRead: selectedIndex, ofArray: csvArray)
            tableMain.reloadData()
        } else {
            print("Index was out of range, not redrawing...")
        }
    }
    
    
    @IBAction func btnBrowse(_ sender: Any) {
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
                self.verifyCSV()
                
            }
        }
    }

    @IBAction func btnPreFlightAction(_ sender: Any) {
        // Setting the delimiter to comma for now--this will be dynamic in the future.
        globalDelimiter = ","

        // Nuke the CSV array on every preflight so we don't get stuck with old data
        csvArray.removeAll()

        // Perform the actual pre-flight checks
        let tabToGoTo = tabViewOutlet.selectedTabViewItem?.identifier as! String
        if tabToGoTo == "objects" {
            attributePreFlightChecks()
        } else if tabToGoTo == "scope" {
            scopePreFlightChecks()
        }


    }
    
    
    func setRecordType() {
        let generalEndpoint = dataPrep.endpoint(csvArray: csvArray)
        if generalEndpoint == "scope" {
            // do stuff based on dropdowns
            if popRecordTypeOutlet.titleOfSelectedItem! == "Computer Prestage" {
                globalEndpoint = "computer-prestages"
                lblScopeType.stringValue = "Serial Number"
                globalTab = "scope"
            } else if popRecordTypeOutlet.titleOfSelectedItem! == "Mobile Device Prestage" {
                globalEndpoint = "mobile-device-prestages"
                lblScopeType.stringValue = "Serial Number"
                globalTab = "scope"
            } else if popRecordTypeOutlet.titleOfSelectedItem! == "Computer Static Group" {
                globalEndpoint = "computergroups"
                lblScopeType.stringValue = "Serial Number"
                globalTab = "scope"
            } else if popRecordTypeOutlet.titleOfSelectedItem! == "Mobile Device Static Group" {
                globalEndpoint = "mobiledevicegroups"
                lblScopeType.stringValue = "Serial Number"
                globalTab = "scope"
            } else if popRecordTypeOutlet.titleOfSelectedItem! == "User Object Static Group" {
                globalEndpoint = "usergroups"
                lblScopeType.stringValue = "Username"
                globalTab = "scope"
            }
            
        } else {
            globalTab = "inventory"
            if generalEndpoint == "users" {
                lblRecordType.stringValue = "Users"
            } else if generalEndpoint == "computers" {
                lblRecordType.stringValue = "Computers"
            } else if generalEndpoint == "mobiledevices" {
                lblRecordType.stringValue = "Mobile Devices"
            }
            globalEndpoint = generalEndpoint
        }
    }
    
    
    
    func drawTables() {
        let currentTab = tabViewOutlet.selectedTabViewItem?.identifier as! String
        if currentTab == "objects" {
            
            // Old tab stuff goes here
            
            //csvData becomes the main table's data. Prints the second row of the CSV, skipping the header.
            csvData = dataPrep.buildDict(rowToRead: 1, ofArray: csvArray)
            //csvIdentifierData contains the data for the Identifier column.
            //csvIdentifierData = dataPrep.buildID(ofArray: csvArray, countArray: csvData)
            csvIdentifierData = dataPrep.buildID(ofArray: csvArray)
            
            /* Must set currentData to the data for the table we're reloading,
             as currentData is used by the numberOfRows function */
            currentData = csvData
            tableMain.reloadData()
            
            currentData = csvIdentifierData
            tblIdentifier.reloadData()
            
        } else if currentTab == "scope" {
            // New tab stuff goes here
            //print("drawTables Function, tab scope...")
            scopeData = dataPrep.buildScopes(ofArray: csvArray)
            //print("csvData: \(scopeData)")
            currentData = scopeData
            //print("currentData should be the same as csvData: \(currentData)")
            tblScopes.reloadData()
        }
        
    }
    

    @IBAction func btnExportCSV(_ sender: Any) {
        NSLog("[INFO  : Saving CSV Templates to User's Downloads Directory")
        CSVMan.ExportCSV()
        _ = popMan.generalWarning(question: "Good Work!", text: "A new directory has been created in your Downloads directory called 'MUT Templates'.\n\nInside that directory, you will find all of the CSV templates you need in order to use MUT v5, along with a ReadMe file on how to fill the templates out.")
    }
    
    @IBAction func submitRequests(_ sender: Any) {
        // This line will need to get re-written when we have dropdowns working for prestage stuff
        globalEndpoint = dataPrep.endpoint(csvArray: csvArray)
        if globalEndpoint != "scope" {
            submitAttributeUpdates()
        } else {
            
            submitScopeUpdates()
        }
        
    }

    @IBAction func btnTest(_ sender: Any) {
        tabViewOutlet.selectTabViewItem(at: 0)
        
    }
    
    @IBAction func btnPrestageTest(_ sender: Any) {
        print(popActionTypeOutlet.selectedItem!.identifier!.rawValue)
        print(popRecordTypeOutlet.selectedItem!.identifier!.rawValue)
    }
    
    func submitScopeUpdates() {
        NSLog("[INFO  : Beginning parsing the CSV file into the array stream.")
        let versionLock = getCurrentPrestageVersionLock(endpoint: popRecordTypeOutlet.selectedItem!.identifier!.rawValue, prestageID: txtPrestageID.stringValue)
        let csvArray = CSVMan.readCSV(pathToCSV: self.globalPathToCSV.path ?? "/dev/null", delimiter: globalDelimiter!)
        //let headerRow = csvArray[0]
        //let numberOfColumns = headerRow.count
        var serialArray: [String]!
        serialArray = []
        if csvArray.count > 1 {
            for row in 1...(csvArray.count - 1) {
                
                // Get the current row of the CSV for updating
                let currentRow = csvArray[row]
                serialArray.append(currentRow[0])

            }
            jsonToSubmit = jsonMan.buildJson(versionLock: versionLock, serialNumbers: serialArray)
            // Submit the XML to the Jamf Pro API
            let response = APIFunc.updatePrestage(passedUrl: globalURL, endpoint: popRecordTypeOutlet.selectedItem!.identifier!.rawValue, prestageID: txtPrestageID.stringValue, jpapiVersion: "v1", token: globalToken, jsonToSubmit: jsonToSubmit, httpMethod: popActionTypeOutlet.selectedItem!.identifier!.rawValue, allowUntrusted: false)
            print(response)
        } else {
            // Not enough rows in the CSV to run
        }
    }
    
    
    func submitAttributeUpdates() {
        // Begin the parse
        NSLog("[INFO  : Beginning parsing the CSV file into the array stream.")
        let csvArray = CSVMan.readCSV(pathToCSV: self.globalPathToCSV.path ?? "/dev/null", delimiter: globalDelimiter!)
        
        // Set variables needed for the run
        var ea_ids = [String]()
        var ea_values = [String]()
        let headerRow = csvArray[0]
        let numberOfColumns = headerRow.count
        
        // Get the expected columns based off update type and calculate number of EAs present
        let expectedColumns = dataPrep.expectedColumns(endpoint: globalEndpoint!)
        
        let numberOfEAs = numberOfColumns - expectedColumns
        
        // If there are EAs, get a list of their EA IDs
        if numberOfEAs > 0 {
            ea_ids = dataPrep.eaIDs(expectedColumns: expectedColumns, numberOfColumns: numberOfColumns, headerRow: headerRow)
        }
        
        // Begin looping through the CSV sheet
        
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
                    if currentRow[1] != "" {
                        // Enforce the mobile device name if the display name field is not blank
                        let xmlToPost = xmlMan.enforceName(deviceName: currentRow[1], serial_number: currentRow[0])
                        let postResponse = APIFunc.enforceName(passedUrl: globalURL, credentials: globalBase64, allowUntrusted: false, xmlToPost: xmlToPost)
                        print(postResponse)
                    }
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
    
    func getCurrentPrestageVersionLock(endpoint: String, prestageID: String) -> Int {
        let myURL = dataPrep.generatePrestageURL(baseURL: globalURL, endpoint: endpoint, prestageID: prestageID, jpapiVersion: "v1")
        print(myURL)
        
        let response = APIFunc.getPrestageScope(passedUrl: myURL, token: globalToken, endpoint: endpoint, allowUntrusted: false)
        let myDataString = String(decoding: response, as: UTF8.self)
        print(myDataString)
        do {
            let newJson = try JSON(data: response)
            let newVersionLock = newJson["versionLock"].intValue
            print(newVersionLock)
            let newSerials = newJson["assignments"][0]["serialNumber"].stringValue
            print(newSerials)
            
            let newSerialArray = newJson["assignments"].arrayValue.map {$0["serialNumber"].stringValue}
            print(newSerialArray)
            
            // print(expiry!) // Uncomment for debugging
            
            return newVersionLock
        } catch let error as NSError {
            NSLog("[ERROR ]: Failed to load: \(error.localizedDescription)")
            return -1
        }
    }
    
    func scopePreFlightChecks() {
        // If the user has actually selected a CSV template, then move on
        if txtCSV.stringValue != "" {
            //get the CSV from the "Browse" button and parse it into an array
            csvArray = CSVMan.readCSV(pathToCSV: self.globalPathToCSV.path!, delimiter: globalDelimiter!)
            if csvArray.count == 0 {
                // If there are no rows in the CSV
                print(csvArray)
                _ = popMan.generalWarning(question: "Empty CSV Found", text: "It seems the CSV file you uploaded is malformed, or does not contain any data.\n\nPlease try a different CSV.")
            } else if csvArray.count == 1 {
                // If there is only 1 row in the CSV (header only)
                _ = popMan.generalWarning(question: "No Data Found", text: "It seems the CSV file you uploaded does not contain any data outside of the header row.\n\nPlease select a CSV with updates for MUT to process.")
            } else {
                // If there is more than 1 column in the CSV
                if csvArray[0].count > 1 {
                    // If the CSV appears to not have good columns -- eg: wrong delimiter
                    _ = popMan.generalWarning(question: "Malformed CSV Found", text: "It seems there are too many columns in your CSV. Please try a different CSV file.\n\nIf you are using a delimiter other than comma, such as semi-colon, please select 'Change Delimiter' from Settings on the Menu bar.")
                } else {
                    // We end up here if all the pre-flight checks have been passed
                    readyToRun()
                    drawTables()
                    setRecordType()
                }
            }
        }
    }
    
    func attributePreFlightChecks() {
        // If the user has actually selected a CSV template, then move on
        if txtCSV.stringValue != "" {
            //get the CSV from the "Browse" button and parse it into an array
            csvArray = CSVMan.readCSV(pathToCSV: self.globalPathToCSV.path!, delimiter: globalDelimiter!)
            
            if csvArray.count == 0 {
                // If there are no rows in the CSV
                _ = popMan.generalWarning(question: "Empty CSV Found", text: "It seems the CSV file you uploaded is malformed, or does not contain any data.\n\nPlease try a different CSV.")
            } else if csvArray.count == 1 {
                // If there is only 1 row in the CSV (header only)
                _ = popMan.generalWarning(question: "No Data Found", text: "It seems the CSV file you uploaded does not contain any data outside of the header row.\n\nPlease select a CSV with updates for MUT to process.")
            } else {
                // If there are less 6 columns in the CSV
                if csvArray[0].count <= 5 {
                    // If the CSV appears to not have good columns -- eg: wrong delimiter
                    _ = popMan.generalWarning(question: "Malformed CSV Found", text: "It seems there are not enough columns in your CSV file. Please try a different CSV file.\n\nIf you are using a delimiter other than comma, such as semi-colon, please select 'Change Delimiter' from Settings on the Menu bar.")
                } else {
                    // We end up here if all the pre-flight checks have been passed
                    readyToRun()
                    drawTables()
                    //lblRecordType.objectValue = "Testing Labels"
                    setRecordType()
                }
            }
        } else {
            _ = popMan.generalWarning(question: "No CSV Found", text: "Please use the Browse button to find a CSV file on your system with updates that you would like MUT to process.")
        }
    }
    
    func verifyCSV() {
        // Nuke the CSV array on every preflight so we don't get stuck with old data
        csvArray.removeAll()
        
        if txtCSV.stringValue != "" {
            //get the CSV from the "Browse" button and parse it into an array
            csvArray = CSVMan.readCSV(pathToCSV: self.globalPathToCSV.path!, delimiter: globalDelimiter!)
            
            globalEndpoint = dataPrep.endpoint(csvArray: csvArray)
            
            if globalEndpoint == "Endpoint_Error" {
                _ = popMan.generalWarning(question: "CSV Error", text: "MUT is not able to read your CSV very well. Please try a different CSV.")
            } else if globalEndpoint == "scope" {
                tabViewOutlet.selectTabViewItem(at: 2)
                preferredContentSize = NSSize(width: 550, height: 600)
                lblStatus.isHidden = false
                lblStatus.stringValue = "It appears you are looking to update a prestage or static group."
            } else {
                tabViewOutlet.selectTabViewItem(at: 1)
                preferredContentSize = NSSize(width: 550, height: 600)
                lblStatus.isHidden = false
                lblStatus.stringValue = "It appears you are looking to update attributes for a record."
            }
            
        } else {
            _ = popMan.generalWarning(question: "No CSV Found", text: "Please use the Browse button to find a CSV file on your system with updates that you would like MUT to process.")
        }
    }
    
    func selectCorrectTab(endpoint: String) {
        if (endpoint == "computers" || endpoint == "users" || endpoint == "mobiledevices") {
            tabViewOutlet.selectTabViewItem(at: 0)
        } else if (endpoint.contains("prestages") || endpoint.contains("groups")){
            tabViewOutlet.selectTabViewItem(at: 1)
        }
    }

    func readyToRun() {
        btnSubmitOutlet.isHidden = false
        btnSubmitOutlet.becomeFirstResponder()
    }

    func notReadyToRun() {
        btnSubmitOutlet.isHidden = true
    }
}


//This entire extension handles the NSTableViews
extension ViewController: NSTableViewDataSource {
    
    //Counts number of rows in each dictionary before drawing cells
    //Unknown how the tableview function uses this value, as we never tell it to explicitly
    //It provides the upper limit to what "row" can be in the tableView function
    func numberOfRows(in tableView: NSTableView) -> Int {
        return (currentData.count)
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        //Initialize variables
        var identifierDict: [String: String] = [:]
        var attributeRow: [String: String] = [:]
        var scopeID: [String: String] = [:]
        //avoid index out of range if there are more rows in the original CSV than there are columns
        if row < csvData.count {
            attributeRow = csvData[row]
        }
        
        //avoid index out of range if there are more columns in the CSV than there are rows
        if csvIdentifierData.count > row {
            identifierDict = csvIdentifierData[row]
        }
        //print("globalTab for tableView is... \(globalTab)")
        if globalTab == "scope" {
            //print("scopeData : \(scopeData)")
            //print("scopeID : \(scopeID)")
            scopeID = scopeData[row]
        }

        
        //The following code matches values from the dictionaries with columns and cells from the tableviews
        //Then returns the cell
        guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return nil }
        //3 columns, so 3 conditions. Right now the last condition is wrapped inside it's own conditional.
        //This may not be necessary
        
/* How this next part works:
 
         - if the tableColumn's identifier is "STRING", then it sets the cell equal to the value in dictionary[key]
         - returns that cell and increments row by 1, starts again.
         - this is repeated until row = rows
         - rows is set by function above this one, numberOfRows
 */
        
        if (tableColumn?.identifier)!.rawValue == "tableAttribute" {
            cell.textField?.stringValue = attributeRow["tableAttribute"] ?? "NO VALUE"
        } else if (tableColumn?.identifier)!.rawValue == "tableValue" {
            cell.textField?.stringValue = attributeRow["tableValue"] ?? "NO VALUE"
            if attributeRow["tableValue"] == "UNCHANGED!" {
                cell.textField?.textColor = NSColor.systemBlue
            }
            else if attributeRow["tableValue"] == "CLEAR!" {
                cell.textField?.textColor = NSColor.systemRed
                //cell.textField?.font = NSFont.boldSystemFont(ofSize: 13.0)
            }
            else {
                cell.textField?.textColor = NSColor.controlTextColor
            }
        } else if (tableColumn?.identifier)!.rawValue == "csvIdentifier" {
            if csvIdentifierData.count > row {
                cell.textField?.stringValue = identifierDict["csvIdentifier"] ?? "NO VALUE"
                
            }
        } else if (tableColumn?.identifier)!.rawValue == "colScopes" {
    
            cell.textField?.stringValue = scopeID["scopeID"] ?? "NO VALUE"
        }
        //This cell will return while row < rows
        //print("returning cell...")
        return cell
    }

}
