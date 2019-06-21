//
//  CSVFunctions.swift
//  The MUT
//
//  Created by Benjamin Whitis on 6/7/19.
//  Copyright © 2019 Levenick Enterprises LLC. All rights reserved.
//

import Foundation
import Cocoa
import CSV

public class CSVManipulation {
    
    let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.appendingPathComponent("MUT Templates")
    let fileManager = FileManager.default

    func ExportCSV() {
        createDirectory()
        exportCSVReadme()
        exportUserCSV()
        exportComputerCSV()
        exportMobileDeviceCSV()
    }
    let userCSV = "Username,Full Name,Email Address,Phone Number,Position,LDAP Server ID\n"
    
    let mobileDeviceCSV = "Mobile Device Serial,Display Name,Asset Tag,Username,Real Name,Email Address,Position,Phone Number,Department,Building,Room,PO Number,Vendor,PO Date,Warranty Expires,Lease Expires\n"
   
    let computerCSV = "Computer Serial,Display Name,Asset Tag,Barcode 1,Barcode 2,Username,Real Name,Email Address,Position,Phone Number,Department,Building,Room,PO Number,Vendor,PO Date,Warranty Expires,Lease Expires\n"
    
    let CSVReadme = "Read this to learn how to use the MUT with Templates!"
    //sort out PO info ordering in CSV. Note Added to Trello
    //Sort out tvOS Airplay Password. Note Added to Trello
    
    func createDirectory(){
        if fileManager.fileExists(atPath: downloadsURL!.path) {
            NSLog("[INFO  ]: Template Directory already exists. Skipping creation.")
        } else {
            NSLog("[INFO  ]: Template Directory does not exist. Creating.")
            do {
                try FileManager.default.createDirectory(at: downloadsURL!, withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSLog("[ERROR ]: An error occured while creating the Template Directory. \(error).")
            }
        }
    }

    func exportCSVReadme() {
        let readmeURL = downloadsURL?.appendingPathComponent("CSVReadme.txt")
        if fileManager.fileExists(atPath: readmeURL!.path) {
            NSLog("[INFO  ]: Readme file already exists. Skipping creation.")
        } else {
            NSLog("[INFO  ]: Readme file does not exist. Creating.")
            do {
                try CSVReadme.write(to: readmeURL!, atomically: false, encoding: .utf8)
            }
            catch {
                NSLog("[ERROR ]: An error occured while creating the Readme. \(error).")
            }
        }

    }
    
    func exportUserCSV() {
        let userURL = downloadsURL?.appendingPathComponent("UserTemplate.csv")
        if fileManager.fileExists(atPath: userURL!.path) {
            NSLog("[INFO  ]: User Template already exists. Skipping creation.")
        } else {
            NSLog("[INFO  ]: User Template does not exist. Creating.")
            do {
                try userCSV.write(to: userURL!, atomically: false, encoding: .utf8)
            }
            catch {
                NSLog("[ERROR ]: An error occured while creating the User Template. \(error).")
            }
        }
    }
    
    func exportMobileDeviceCSV() {
        let mobileURL = downloadsURL?.appendingPathComponent("MobileDeviceTemplate.csv")
        if fileManager.fileExists(atPath: mobileURL!.path) {
            NSLog("[INFO  ]: Mobile Template already exists. Skipping creation.")
        } else {
            NSLog("[INFO  ]: Mobile Template does not exist. Creating.")
            do {
                try mobileDeviceCSV.write(to: mobileURL!, atomically: false, encoding: .utf8)
            }
            catch {
                NSLog("[ERROR ]: An error occured while creating the Mobile Template. \(error).")
            }
        }
    }

    func exportComputerCSV() {
        let computerURL = downloadsURL?.appendingPathComponent("ComputerTemplate.csv")
        if fileManager.fileExists(atPath: computerURL!.path) {
            NSLog("[INFO  ]: Computer Template already exists. Skipping creation.")
        } else {
            NSLog("[INFO  ]: Computer Template does not exist. Creating.")
            do {
                try computerCSV.write(to: computerURL!, atomically: false, encoding: .utf8)
            }
            catch {
                NSLog("[ERROR ]: An error occured while creating the Computer Template. \(error).")
            }
        }
    }

    func readCSV(pathToCSV: String) -> [[String]]{
        let stream = InputStream(fileAtPath: pathToCSV)!

        // Initialize the array
        var csvArray = [[String]]()
        let csv = try! CSVReader(stream: stream)

        // For each row in the CSV, append it to the end of the array
        while let row = csv.next() {
            csvArray = (csvArray + [row])
        }
        return csvArray
    }
}

    
    
    

