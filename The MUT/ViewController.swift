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

class ViewController: NSViewController, URLSessionDelegate, NSTableViewDelegate, DataSentDelegate {
    
    // Declare outlets for Buttons to change color and hide/show
    @IBOutlet weak var btnSubmitOutlet: NSButton!
    @IBOutlet weak var btnPreFlightOutlet: NSButton!
    
    // Declare outlet for entire controller
    @IBOutlet var MainViewController: NSView!
    
    // Outlet for Logging text window and scroll view
    @IBOutlet var txtMain: NSTextView!
    @IBOutlet weak var txtMainWrapper: NSScrollView!
    
    //tableMain
    @IBOutlet weak var tableMain: NSTableView!
    //Identifier Table
    @IBOutlet weak var tblIdentifier: NSTableView!
    //@IBOutlet weak var identifierHeader: NSTableHeaderView!
    //@IBOutlet weak var identifierText: NSTextField!
    
    
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
    
    func userDidAuthenticate(base64Credentials: String, url: String, token: String, expiry: Int) {
        globalExpiry = expiry
        globalToken = token
        globalURL = url
        globalBase64 = base64Credentials
    }
    
    let dataPrep = dataPreparation()
    let tokenMan = tokenManagement()
    let xmlMan = xmlManager()
    let CSVMan = CSVManipulation()
    let APIFunc = APIFunctions()
    
    var currentData : [[String: String]] = []
    
    var csvData : [[ String : String ]] = []
    var csvIdentifierData = [
        [
            "csvIdentifier" : "Benjadmin"
        ],
        [
            "csvIdentifier" : "Billyjo"
        ]
    ]
    
    
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
    func readCSV(pathToCSV: String) -> [[String]]{
        //print("begin readCSV...")
        let stream = InputStream(fileAtPath: pathToCSV)!
        csvArray = [[String]]()
        let csv = try! CSVReader(stream: stream)
        while let row = csv.next() {
            print("\(row)")
            csvArray = (csvArray + [row])
        }
        //print("Printed csvArray: \(csvArray)")
        return csvArray
    }
    
    
    
    @IBAction func btnPreFlightAction(_ sender: Any) {
        //submitUpdates()
        //testUpdates()
        drawTables()
    }
    
    
    func drawTables() {
        let csvArray = readCSV(pathToCSV: self.globalPathToCSV.path!)
        //        print("")
        //        print("Running Build Dict")
        //        print("")
        
        csvData = buildDict(rowToRead: 1, ofArray: csvArray)
        csvIdentifierData = buildID(ofArray: csvArray, countArray: csvData)
        
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
        let csvArray = CSVMan.readCSV(pathToCSV: self.globalPathToCSV.path ?? "/dev/null")
        
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

   
    
}



extension ViewController: NSTableViewDataSource {
    //this one is definitely in use
    func numberOfRows(in tableView: NSTableView) -> Int {
        return (currentData.count)
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var csvID: [String: String] = [:]
        let user = csvData[row]
        if csvIdentifierData.count > row {
            csvID = csvIdentifierData[row]
        }
        //        print("")
        //        print("csvData looks like: \(csvData[row])")
        //        print("")
        //        print("csvIdentifierData looks like: \(csvIdentifierData[row])")
        //        print("")
        //        print("Row is... \(row)")
        //        print("Printing csvData at Start of tableView... \(csvArray[0])")
        
        guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return nil }
        
        if (tableColumn?.identifier)!.rawValue == "tableAttribute" {
            cell.textField?.stringValue = user["tableAttribute"] ?? "NO VALUE"
        } else if (tableColumn?.identifier)!.rawValue == "tableValue" {
            cell.textField?.stringValue = user["tableValue"] ?? "NO VALUE"
        } else if (tableColumn?.identifier)!.rawValue == "csvIdentifier" {
            if csvIdentifierData.count > row {
                cell.textField?.stringValue = csvID["csvIdentifier"] ?? "NO VALUE"
            }
        }
        
        return cell
    }
    
    
    func readUser() {
        let user = csvData[0]
        print(user)
        print("Attribute is... \(user["tableAttribute"] ?? "nil")")
        print("Value is... \(user["tableValue"] ?? "nil")")
    }
    
}

func buildDict(rowToRead: Int, ofArray: [[String]]) -> [[String : String]] {
    //print("Beginning buildDict using array: \(ofArray)")
    //NOTE: If we allow not using header rows, this will need to be hard coded.
    //Otherwise, we can read in the header row. This would be easier if using EAs
    let headerRow = ofArray[0]
    
    //how many attributes are there
    let columns = headerRow.count
    //start at the first attribute
    var column = 0
    //How many records are in the csv (rows)
    let entries = ofArray.count
    //Start at first record, skipping header row
    var entry = 1
    var currentEntry = [""]
    //Will append to the returnArray throughout the loops
    var returnArray: [[ String : String ]] = []
    
    //print("Number of columns in headerRow: \(columns)")
    
    //Unsure if this line is needed
    column = 0
    
    //set row to whatever is input for row to read. Can be hard coded, or we can increment it
    currentEntry = ofArray[rowToRead]
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
    entry += 1
    
    //print("Return Array... \(returnArray)")
    
    return returnArray
}

func buildID (ofArray: [[String]], countArray: [[String: String]]) -> [[String: String]] {
    print("Beginning buildID...")
    var dictID: [[String: String]] = []
    var rows = ofArray.count
    //Hard Code maximum displayed identifiers for preview.
    //Since we skip to row 1 (row 0 is header), setting to 6 will give us 5 rows.
    // Right now 6 entries is the greatest it can do for users, as that's how many fields are displayed in the other table.
    if rows > 7 {
        rows = 7
    }
    var row = 1
    //start at second entry in CSV to skip Username/SerialNumber
    var currentRow: [String] = []
    while row < rows {
        currentRow = ofArray[row]
        dictID.append(["csvIdentifier" : currentRow[0]])
        row += 1
    }
    
    return dictID
    
}
