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
    
    // Declare outlets for Buttons to change color and hide/show
    @IBOutlet weak var btnSubmitOutlet: NSButton!
    @IBOutlet weak var btnPreFlightOutlet: NSButton!
    
    // Declare outlet for entire controller
    @IBOutlet var MainViewController: NSView!
    
    // Outlet for Logging text window and scroll view
    @IBOutlet var txtMain: NSTextView!
    @IBOutlet weak var txtMainWrapper: NSScrollView!
    
    //MARK: TableView Outlets and actions
    //tableMain
    @IBOutlet weak var tableMain: NSTableView!
    //Identifier Table
    @IBOutlet weak var tblIdentifier: NSTableView!
    //@IBOutlet weak var identifierHeader: NSTableHeaderView!
    //@IBOutlet weak var identifierText: NSTextField!
    
    //btnIdentifier reloads tableMain based on the index of the selected row in Identifier table
    @IBAction func btnIdentifier(_ sender: Any) {
        currentData = csvData
        let selectedIndex = tblIdentifier.clickedRow + 1
        print("Selected Index is... \(selectedIndex)")
        let maxIndex = csvArray.count
        if selectedIndex == 0 {
            print("selectedIndex is 0, not redrawing...")
        } else if
            selectedIndex < maxIndex {
            csvData = buildDict(rowToRead: selectedIndex, ofArray: csvArray)
            tableMain.reloadData()
        } else {
            print("Index was out of range, not redrawing...")
        }
    }
    
    
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
    var globalDelimiter: UnicodeScalar!
    
    func userDidAuthenticate(base64Credentials: String, url: String, token: String, expiry: Int) {
        globalExpiry = expiry
        globalToken = token
        print("Token is: \(token)")
        globalURL = url
        globalBase64 = base64Credentials
    }
    
    let dataPrep = dataPreparation()
    let tokenMan = tokenManagement()
    let xmlMan = xmlManager()
    let CSVMan = CSVManipulation()
    let APIFunc = APIFunctions()
    
    
    //Variables used by tableViews
    var currentData : [[String: String]] = []
    var csvData : [[ String : String ]] = []
    var csvIdentifierData: [[String: String]] = []

    
    
    
    
    
    //MARK: GUI Experimentation
    
 
    @IBOutlet weak var lblRecordType: NSTextField!
    
    
   
    
    
    
    
    
    
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

    var csvArray = [[String]]()
    
    @IBAction func btnPreFlightAction(_ sender: Any) {
        globalDelimiter = ","
        //submitUpdates()

        //testUpdates()
        drawTables()
        //lblRecordType.objectValue = "Testing Labels"
        setRecordType()

    }
    
    
    func setRecordType() {
        let headerRow = csvArray[0]
        print("RecType... HeaderRow... \(headerRow)")
        let record = headerRow[0]
        print("recType... record... \(record)")
        
        print("Record is: \(record )")
        
        print("headerRow 0 : headerRow 3... \(headerRow[0]) : \(headerRow[3])")
        
        if headerRow[0] == "Username" {
            lblRecordType.objectValue = "Users"
            
        } else if
            headerRow[2] == "Username" {
            
           lblRecordType.objectValue = "Mobile Devices"
        } else if
            headerRow[2] == "Barcode 1" {
            lblRecordType.objectValue = "Computers"
        }
        
    
    }
    
    
    
    func drawTables() {
        //        print("")
        //        print("Running Build Dict")
        //        print("")

        //get the CSV from the "Browse" button and parse it into an array
        csvArray = CSVMan.readCSV(pathToCSV: self.globalPathToCSV.path!, delimiter: globalDelimiter!)
        print("")
        print("Running Build Dict")
        print("")
        //csvData becomes the main table's data. Prints the second row of the CSV, skipping the header.
        csvData = buildDict(rowToRead: 1, ofArray: csvArray)
        //csvIdentifierData contains the data for the Identifier column.
        csvIdentifierData = buildID(ofArray: csvArray, countArray: csvData)
        
        /* Must set currentData to the data for the table we're reloading,
         as currentData is used by the numberOfRows function */
        currentData = csvData
        tableMain.reloadData()
        
        currentData = csvIdentifierData
        tblIdentifier.reloadData()
        
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
        let csvArray = CSVMan.readCSV(pathToCSV: self.globalPathToCSV.path ?? "/dev/null", delimiter: globalDelimiter!)
        
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
    
    func testUpdates() {
        let myURL = dataPrep.generateGetURL(baseURL: globalURL, endpoint: "computer-prestages", prestageID: "1", jpapiVersion: "v1")
        print(myURL)
        
        let response = APIFunc.getPrestageScope(passedUrl: myURL, token: globalToken, endpoint: "computer-prestages", allowUntrusted: true)
        let myDataString = String(decoding: response, as: UTF8.self)
        do {
            let newJson = try JSON(data: response)
            let newVersionLock = newJson["versionLock"].intValue
            print(newVersionLock)
            let newSerials = newJson["assignments"][0]["serialNumber"].stringValue
            print(newSerials)
            
            let newSerialArray = newJson["assignments"].arrayValue.map {$0["serialNumber"].stringValue}
            print(newSerialArray)
            
            // print(expiry!) // Uncomment for debugging
        } catch let error as NSError {
            NSLog("[ERROR ]: Failed to load: \(error.localizedDescription)")
        }
    
        print(myDataString)
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

        //avoid index out of range if there are more rows in the original CSV than there are columns
        if row < csvData.count {
            attributeRow = csvData[row]
        }
        
        //avoid index out of range if there are more columns in the CSV than there are rows
        if csvIdentifierData.count > row {
            identifierDict = csvIdentifierData[row]
        }
     
        
        //The following code matches values from the dictionaries with columns and cells from the tableviews
        //Then returns the cell
        guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return nil }
        //3 columns, so 3 conditions. Right now the last condition is wrapped inside it's own conditional.
        //This may not be necessary
        if (tableColumn?.identifier)!.rawValue == "tableAttribute" {
            cell.textField?.stringValue = attributeRow["tableAttribute"] ?? "NO VALUE"
        } else if (tableColumn?.identifier)!.rawValue == "tableValue" {
            cell.textField?.stringValue = attributeRow["tableValue"] ?? "NO VALUE"
        } else if (tableColumn?.identifier)!.rawValue == "csvIdentifier" {
            if csvIdentifierData.count > row {
                cell.textField?.stringValue = identifierDict["csvIdentifier"] ?? "NO VALUE"
            }
        }
        
        return cell
    }
    
}


//Builds a dictionary of all attributes being modified, pairing key-values for every attribute
func buildDict(rowToRead: Int, ofArray: [[String]]) -> [[String : String]] {
    //print("Beginning buildDict using array: \(ofArray)")
    
    //reads in the header row for the keys. Would handle any header row.
    let headerRow = ofArray[0]
    
    //how many attributes are there
    let columns = headerRow.count
    //start at the first attribute
    var column = 0

    //Start at first record, skipping header row
    
    var currentEntry = [""]
    //Will append to the returnArray throughout the loops
    var returnArray: [[ String : String ]] = []
    
    //print("Number of columns in headerRow: \(columns)")
    
    //start at first column
    column = 0
    
    //set row to whatever is input for row to read. Can be hard coded, or we can increment it
    currentEntry = ofArray[rowToRead]
    //go through each column, pairing headerRow for attribute with the value from the row.
    while column < columns {
        //print("Current Entry... \(currentEntry[column])")
        var builderTwo: [String : String] = [:]
        if currentEntry[column] == "" {
            builderTwo = ["tableAttribute" : headerRow[column], "tableValue" : "_UNCHANGED_"]
        } else {
            builderTwo = ["tableAttribute" : headerRow[column], "tableValue" : currentEntry[column]]
        }
        returnArray.append(builderTwo)
        column += 1
    }
    
    //print("buildDict's return array... \(returnArray)")
    
    /* returnArray will be for ONE row from original CSV, row specified by the rowToRead variable
     Format will be a series of entries like this:
     ["tableAttribute": "Username", "tableValue": "myName"], ["tableAttribute": "Full Name", "tableValue": "Myfull Name"], etc for however many columns are in the header row
    */
    return returnArray
}

func buildID (ofArray: [[String]], countArray: [[String: String]]) -> [[String: String]] {
    print("Beginning buildID...")
    var dictID: [[String: String]] = []
    var rows = ofArray.count
    //Hard Code maximum displayed identifiers for preview.
    //Since we skip to row 1 (row 0 is header), setting to 6 will give us 5 rows.
    //Unsure if this still works
//    if rows > 7 {
//        rows = 7
//    }
    var row = 1
    //start at second entry in CSV to skip headers
    var currentRow: [String] = []
    while row < rows {
        currentRow = ofArray[row]
        dictID.append(["csvIdentifier" : currentRow[0]])
        row += 1
    }
    
    //print("dictID is... \(dictID)")
    /* returns a dictionary pairing "csvIdentifier" with the username/serial number from original csv.
     Looks like:
     [["csvIdentifier": "Benji"], ["csvIdentifier": "Billy"]]
     */
    return dictID
}
