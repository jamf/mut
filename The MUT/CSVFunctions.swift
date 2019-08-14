//
//  CSVFunctions.swift
//  The MUT
//
//  Created by Benjamin Whitis on 6/7/19.
//  Copyright © 2019 Levenick Enterprises, LLC. All rights reserved.
//

import Foundation
import Cocoa
import CSV

public class CSVManipulation {
    let popMan = popPrompt()
    let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
    let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.appendingPathComponent("MUT Templates")
    let fileManager = FileManager.default
    let logMan = logManager()

    func ExportCSV() {
        createDirectory()
        exportCSVReadme()
        exportUserCSV()
        exportComputerCSV()
        exportMobileDeviceCSV()
        exportGroupCSV()
        copyReadme()
        //_ = popMan.generalWarning(question: "Good Work!", text: "A new directory has been created in your Downloads directory called 'MUT Templates'.\n\nInside that directory, you will find all of the CSV templates you need in order to use MUT v5, along with a ReadMe file on how to fill the templates out.")
        let pathToOpen = downloadsDirectory!.resolvingSymlinksInPath().standardizedFileURL.absoluteString.replacingOccurrences(of: "file://", with: "") + "MUT Templates/"
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: pathToOpen)
    }
    let userCSV = "Current Username,New Username,Full Name,Email Address,Phone Number,Position,LDAP Server ID,Site (ID or Name),Managed Apple ID (Requires Jamf Pro 10.15+)\n"
    
    let mobileDeviceCSV = "Mobile Device Serial,Display Name,Asset Tag,Username,Real Name,Email Address,Position,Phone Number,Department,Building,Room,PO Number,Vendor,PO Date,Warranty Expires,Lease Expires,Site (ID or Name),Airplay Password (tvOS Only)\n"
   
    let computerCSV = "Computer Serial,Display Name,Asset Tag,Barcode 1,Barcode 2,Username,Real Name,Email Address,Position,Phone Number,Department,Building,Room,PO Number,Vendor,PO Date,Warranty Expires,Lease Expires,Site (ID or Name)\n"
    
    let groupCSV = "Serial Numbers or Usernames\n"
    
    let CSVReadme = """
The MUT is a multi-use tool that uses both Jamf Pro's classic API, and the new Jamf Pro API to make changes en masse to inventory records for Computers, Devices, and Users. The MUT can also be used to add, remove, or replace Computers and Mobile Devices in Static Groups and PreStage Enrollments.

Detailed Guides and Screenshots can be found here: https://github.com/mike-levenick/mut/blob/master/README.md

----------------------------------
Table of Contents:

1) Logging In
2) CSV Templates
    - 2a) Updating a Single Attribute
    - 2b) Clearing Values
    - 2c) Extension Attributes
3) Previewing CSV Data
4) Object View
5) Scope View
----------------------------------

1) Logging In

- When launched, The MUT prompts for:

a) Cloud instance or full URL. This field is expecting either:
    i) A full Jamf Pro URL
    ii) If using JamfCloud, the server instance name can be entered (for example, if you have "jssmut.jamfcloud.com" you could just enter "jssmut" as your instance name).
b) Username
c) Password

    The MUT uses the credentials provided to generate a session token that will be used for prestage API calls. This token is valid 30 minutes. If the 30 minute session has expired, the MUT can be relaunched to generate a new token.
----------------------------------

2) CSV Templates

    CSV Templates can be created after passing the authentication screen. The MUT verifies the headers of the CSV template being uploaded in order to determine which endpoints to use, so it is important to use the CSV templates provided without any alterations to the header row, except for adding extension attributes.

    When "Download CSV Templates" is selected, the MUT will place a folder inside of the Downloads directory, named "MUT Templates." If the directory already exists, the MUT will check for the presense of each individual template, the README, and the MUT.log. If any of these files already exist, they will not be overwritten.

- 2a) Updating a Single Attribute

    If a CSV template contains empty fields, those fields are ignored by The MUT. To update just one attribute, leave the other columns blank. The MUT will skip over those columns when submitting the changes to Jamf Pro.

    When previewing this data after uploading, the MUT will display "(unchanged)" in blue text for all values that will be skipped when submitting.

2b) Clearing Values

    Because the MUT ignores empty values, a specific string must be used to tell the MUT to clear those values, rather than skipping over them. The string is: CLEAR!

    When "CLEAR!" is entered for a value, the MUT will display this value in the preview table as "WILL BE CLEARED" in red text.

2c) Extension Attributes

    For Computers, Mobile Devices, and Users, extra columns can be added to the end of the CSV templates for Extension Attributes. The Extension Attribute to update must be designated by its ID in the Header Row of the CSV.

    An Extension Attribute's ID can be identified by visiting the Extension Attribute in a browser and viewing its URL.

    For example: If adding a Computer Extension attribute, navigate to Jamf Pro > Settings > Computer Management > Extension Attributes > Click on the Attribute in question.

    The Extension Attribute's ID can be found within the URL at this page. If the URL is:
    https://YourInstance.jamfcloud.com/computerExtensionAttributes.html?id=5&o=r
    Then the Extension Attribute's ID = 5.
    In the Header Row of the CSV add: EA_5
----------------------------------

3) Previewing CSV Data

    To select a CSV to preview, click "Browse for Filled Out CSV". The MUT checks the CSV to make sure the headers are formatted correctly, and will provide feedback if the headers are not correct.

    After verifying valid headers, the MUT automatically displays either the Object View or Scope View depending on the CSV headers.
----------------------------------

4) Object View

The Object view is displayed when any of the following CSV templates are selected:
    - ComputerTemplate
    - MobileDeviceTemplate
    - UserTemplate

    In the Object View, three columns are displayed. The far left column will display a list of every Computer, Mobile Device, or User in the CSV. Each entry in the far left column can be selected (by clicking on the entry) to view what specifically will be changed.

    The far right column is color coded for ease of reading. Values that appear as the default text color will be updated. Values that appear as "(unchanged)" in blue will not be updated by the MUT. Values that appear as "WILL BE CLEARED" in red will be cleared by the MUT.

    After verifying the imported data is correct, the updates from the CSV can be pushed to the Jamf Pro server by hitting the "Submit Updates" button.

    When updates are processing, a progress bar will appear indicating which line is currently being processed, and a "Cancel" button will appear. The "Cancel" button will stop the MUT at the line it is currently processing.
----------------------------------

5) Scope View

    If a single column CSV is selected, the Scope view is displayed.

    The table on the left side will display a list of all items in the CSV.

    Options must be selected in the dropdowns on the right side of the Scope view. The top dropdown determines the type of record to update. The options are:
        - Computer Prestage
        - Mobile Device Prestage
        - Computer Static Group
        - Mobile Device Static Group
        - User Object Static Group

    After an option is selected in the top dropdown, the second dropdown is selectable. In this dropdown choose to do one of three things:
        - Add: Keep existing members of the Group/Prestage in place, and add those in the CSV to the Group/Prestage
        - Remove: Remove the designated members from the Group/Prestage
        - Replace: Clear out the existing members of the Group/Prestage, and replace them with those the members in the CSV.

    Lastly, define the Prestage ID, or Static Group ID.

    This can be done by visiting the Prestage or Static Group in a web browser, and viewing the browser URL. Below are examples for both a Prestage and a Static Group:

    Prestage: If the URL is https://YourInstance.jamfcloud.com/mobileDevicePrestage.html?id=3&o=r
    then the ID = 3.
    In the Prestage ID field enter: 3

    Static Group: If the URL is https://YourInstance.jamfcloud.com/staticMobileDeviceGroups.html?id=4&o=r
    Then the ID = 4.
    In the Static Group ID field enter: 4

    After selecting the desired Static Group or PreStage, and the action to perform on that selection, the updates from the CSV can be pushed to the Jamf Pro server by hitting the "Submit Updates" button.

    When updates are processing, a progress bar will appear indicating which line is currently being processed, and a "Cancel" button will appear. The "Cancel" button will stop the MUT at the line it is currently processing.

"""
    //sort out PO info ordering in CSV. Note Added to Trello
    //Sort out tvOS Airplay Password. Note Added to Trello
    
    func createDirectory(){
        if fileManager.fileExists(atPath: downloadsURL!.path) {
            //NSLog("[INFO  ]: Template Directory already exists. Skipping creation.")
            //logMan.infoWrite(logString: "Template Directory already exists. Skipping creation.")
        } else {
            //NSLog("[INFO  ]: Template Directory does not exist. Creating.")
            logMan.infoWrite(logString: "Template Directory does not exist. Creating. \(downloadsURL!.path)")
            do {
                try FileManager.default.createDirectory(at: downloadsURL!, withIntermediateDirectories: true, attributes: nil)
            } catch {
                //NSLog("[ERROR ]: An error occured while creating the Template Directory. \(error).")
                logMan.errorWrite(logString: "An error occured while creating the Template Directory. \(error).")
            }
        }
    }

    func exportCSVReadme() {
        let readmeURL = downloadsURL?.appendingPathComponent("ReadMe.txt")
        if fileManager.fileExists(atPath: readmeURL!.path) {
            //NSLog("[INFO  ]: Readme file already exists. Skipping creation.")
            logMan.infoWrite(logString: "ReadMe file already exists. Skipping creation.")
        } else {
            //NSLog("[INFO  ]: Readme file does not exist. Creating.")
            logMan.infoWrite(logString: "ReadMe file does not exist. Creating.")
            do {
                try CSVReadme.write(to: readmeURL!, atomically: false, encoding: .utf8)
            }
            catch {
                //NSLog("[ERROR ]: An error occured while creating the Readme. \(error).")
                logMan.errorWrite(logString: "An error occured while creating the Readme. \(error).")
            }
        }
    }
    
    func exportUserCSV() {
        let userURL = downloadsURL?.appendingPathComponent("UserTemplate.csv")
        if fileManager.fileExists(atPath: userURL!.path) {
            //NSLog("[INFO  ]: User Template already exists. Skipping creation.")
            logMan.infoWrite(logString: "User Template already exists. Skipping creation.")
        } else {
            //NSLog("[INFO  ]: User Template does not exist. Creating.")
            logMan.infoWrite(logString: "User Template does not exist. Creating.")
            do {
                try userCSV.write(to: userURL!, atomically: false, encoding: .utf8)
            }
            catch {
                //NSLog("[ERROR ]: An error occured while creating the User Template. \(error).")
                logMan.errorWrite(logString: "An error occured while creating the User Template. \(error).")
            }
        }
    }
    
    func exportMobileDeviceCSV() {
        let mobileURL = downloadsURL?.appendingPathComponent("MobileDeviceTemplate.csv")
        if fileManager.fileExists(atPath: mobileURL!.path) {
            //NSLog("[INFO  ]: Mobile Template already exists. Skipping creation.")
            logMan.infoWrite(logString: "Mobile Template already exists. Skipping creation.")
        } else {
            //NSLog("[INFO  ]: Mobile Template does not exist. Creating.")
            logMan.infoWrite(logString: "Mobile Template does not exist. Creating.")
            do {
                try mobileDeviceCSV.write(to: mobileURL!, atomically: false, encoding: .utf8)
            }
            catch {
                //NSLog("[ERROR ]: An error occured while creating the Mobile Template. \(error).")
                logMan.errorWrite(logString: "An error occured while creating the Mobile Template. \(error).")
            }
        }
    }

    func exportComputerCSV() {
        let computerURL = downloadsURL?.appendingPathComponent("ComputerTemplate.csv")
        if fileManager.fileExists(atPath: computerURL!.path) {
            //NSLog("[INFO  ]: Computer Template already exists. Skipping creation.")
            logMan.infoWrite(logString: "Computer Template already exists. Skipping creation.")
        } else {
            //NSLog("[INFO  ]: Computer Template does not exist. Creating.")
            logMan.infoWrite(logString: "Computer Template does not exist. Creating.")
            do {
                try computerCSV.write(to: computerURL!, atomically: false, encoding: .utf8)
            }
            catch {
                //NSLog("[ERROR ]: An error occured while creating the Computer Template. \(error).")
                logMan.errorWrite(logString: "An error occured while creating the Computer Template. \(error).")
            }
        }
    }
    
    func exportGroupCSV() {
        let groupURL = downloadsURL?.appendingPathComponent("GroupsAndPrestagesTemplate.csv")
        if fileManager.fileExists(atPath: groupURL!.path) {
            //NSLog("[INFO  ]: Computer Template already exists. Skipping creation.")
            logMan.infoWrite(logString: "Group/Prestage Template already exists. Skipping creation.")
        } else {
            //NSLog("[INFO  ]: Computer Template does not exist. Creating.")
            logMan.infoWrite(logString: "Group/Prestage Template does not exist. Creating.")
            do {
                try groupCSV.write(to: groupURL!, atomically: false, encoding: .utf8)
            }
            catch {
                //NSLog("[ERROR ]: An error occured while creating the Computer Template. \(error).")
                logMan.errorWrite(logString: "An error occured while creating the Group/Prestage Template. \(error).")
            }
        }
    }
    
    func copyReadme() {
        let readmeURL = (downloadsURL?.appendingPathComponent("README.pdf"))!
        guard let sourceURL = Bundle.main.url(forResource: "README", withExtension: "pdf")
            else {
                logMan.errorWrite(logString: "Error with getting the URL of the README file.")
                return
            }
        let fileManager = FileManager.default
        do {
            try fileManager.copyItem(at: sourceURL, to: readmeURL)
        } catch {
            logMan.errorWrite(logString: "Error copying the readme file to the templates directory.")
        }
    }

    func readCSV(pathToCSV: String, delimiter: UnicodeScalar) -> [[String]]{
        let stream = InputStream(fileAtPath: pathToCSV)!

        // Initialize the array
        var csvArray = [[String]]()
        let csv = try! CSVReader(stream: stream, delimiter: delimiter)

        // For each row in the CSV, append it to the end of the array
        while let row = csv.next() {
            csvArray = (csvArray + [row])
        }
        return csvArray
    }
    

}

    
    
    

