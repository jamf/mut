//
//  CSVFunctions.swift
//  The MUT
//
//  Created by Benjamin Whitis on 6/7/19.
//  Copyright © 2019 Levenick Enterprises LLC. All rights reserved.
//

import Foundation
import Cocoa

public class CSVManipulation {
    
    let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
    
    func ExportCSV() {
        createDirectory()
        exportCSVReadme()
        exportUserCSV()
        exportComputerCSV()
        exportMobileDeviceCSV()
    }
    
    
    let usersCSV = "Username,Full Name,Email Address,Phone Number,Position,LDAP Server ID\n"
    
    let mobileDeviceCSV = "Display Name,Asset Tag,Username,Real Name,Email Address,Position,Phone Number,Department,Building,Room,PO Number,Vendor,PO Date,Warranty Expires,Lease Expires\n"
   
    let computerCSV = "Display Name,Asset Tag,Barcode 1,Barcode 2,Username,Real Name,Email Address,Position,Phone Number,Department,Building,Room,PO Number,Vendor,PO Date,Warranty Expires,Lease Expires\n"
    
    let CSVReadme = "Read this to learn how to use the MUT with Templates!"
    //sort out PO info ordering in CSV. Note Added to Trello
    //Sort out tvOS Airplay Password. Note Added to Trello
    
    
    func exportCSVReadme() {
        print("Starting CSVReadme")
        
        let fileURL = downloadsURL?.appendingPathComponent("MUT Templates/CSVReadme.txt")
        
        do {
            try CSVReadme.write(to: fileURL!, atomically: false, encoding: .utf8)
        }
        catch {
            print("error took place: \(error)")
        }
    }
    
    func exportUserCSV() {
        
        
        print("Starting ExportUserCSV")
        
        let fileURL = downloadsURL?.appendingPathComponent("MUT Templates/UserTemplate.csv")
        
        do {
        
            try usersCSV.write(to: fileURL!, atomically: false, encoding: .utf8)
        }
        catch {
            print("error took place: \(error)")
        }
        
    }
    
    func exportMobileDeviceCSV() {
        print("Starting MobileDeviceCSV")
        
        let fileURL = downloadsURL?.appendingPathComponent("MUT Templates/MobileDeviceTemplate.csv")
        
        do {
  
            try mobileDeviceCSV.write(to: fileURL!, atomically: false, encoding: .utf8)
        }
        catch {
            print("error took place: \(error)")
        }
    }
    func exportComputerCSV() {
        print("Starting ComputerCSV")
        
        let fileURL = downloadsURL?.appendingPathComponent("MUT Templates/ComputerTemplate.csv")
        
        do {
            try computerCSV.write(to: fileURL!, atomically: false, encoding: .utf8)
        }
        catch {
            print("error took place: \(error)")
        }
    }
    
    func createDirectory(){
        
        let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        do {
        try FileManager.default.createDirectory(at: downloadsURL!.appendingPathComponent("MUT Templates"), withIntermediateDirectories: true, attributes: nil)
        } catch {
        print(error)
        }
    }
}

    
    
    

