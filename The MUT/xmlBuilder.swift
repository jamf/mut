//
//  xmlBuilder.swift
//  The MUT
//
//  Created by Michael Levenick on 4/17/17.
//  Copyright © 2017 Levenick Enterprises LLC. All rights reserved.
//

import Cocoa
import Foundation

public class xmlBuilder {
    var formattedEndpoint = ""
    var xml: XMLDocument?
    
    public func createPUTURL(url: String, endpoint: String, idType: String, columnA: String) -> URL {
        let stringURL = "\(url)\(endpoint)/\(idType)/\(columnA)"
        let urlwithPercentEscapes = stringURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        let encodedURL = NSURL(string: urlwithPercentEscapes!)
        return encodedURL! as URL
    }
    
    public func createPOSTURL(url: String) -> URL {
        let stringURL = "\(url)mobiledevicecommands/command/DeviceName"
        let encodedURL = NSURL(string: stringURL)
        return encodedURL! as URL
    }
    
    public func createGETURL(url: String) -> URL {
        let stringURL = "\(url)activationcode"
        let encodedURL = NSURL(string: stringURL)
        return encodedURL! as URL
    }
    
    public func createXML(popIdentifier: String, popDevice: String, popAttribute: String, eaID: String, columnB: String, columnA: String) -> Data {
        var returnedXML: Data?
        
        let xmlDevice = ["macOS Devices": "computer", "iOS Devices": "mobile_device", "Users": "user"][popDevice]
        
        let xmlSubset = ["Asset Tag": "general", "Device Name": "general", "Site by ID": "general", "Site by Name": "general", "Username": "location", "Full Name": "location", "Email": "location", "Position": "location", "Department": "location", "Building": "location", "Room": "location", "Extension Attribute": "extension_attributes", "User's Username": "", "User's Full Name": "", "Email Address": "", "User's Position": "", "Phone Number": "", "User's Site by ID": "sites", "User's Site by Name": "sites", "User Extension Attribute": "extension_attributes", "PO Number": "purchasing"][popAttribute]
        
        let xmlAttribute = ["Asset Tag": "asset_tag", "Device Name": "name", "Site by ID": "site", "Site by Name": "site", "Username": "username", "Full Name": "real_name", "Email": "email_address", "Position": "position", "Department": "department", "Building": "building", "Room": "room", "Extension Attribute": "extension_attribute", "User's Username": "name", "User's Full Name": "full_name", "Email Address": "email", "User's Position": "position", "Phone Number": "phone_number", "User's Site by ID": "site", "User's Site by Name": "site", "User Extension Attribute": "extension_attribute", "macOS Static Group": "computer_group", "PO Number":"po_number"][popAttribute]
        
        let xmlExtra = ["Asset Tag": "", "Device Name": "", "Site by ID": "id", "Site by Name": "name", "Username": "", "Full Name": "", "Email": "", "Position": "", "Department": "", "Building": "", "Room": "", "Extension Attribute": "value", "User's Username": "", "User's Full Name": "", "Email Address": "", "User's Position": "", "Phone Number": "", "User's Site by ID": "id", "User's Site by Name": "name", "User Extension Attribute": "value", "PO Number":""][popAttribute]
        
        // BUILD XML FOR macOS STATIC GROUP
        if xmlAttribute == "computer_group" {
            let root = XMLElement(name: "computer_group")
            let xml = XMLDocument(rootElement: root)
            let subset = XMLElement(name: "computer_additions")
            let child = XMLElement(name: "computer")
            let identifier = XMLElement(name: "serial_number", stringValue: columnA)
            //let value = XMLElement(name: "value", stringValue: columnB)
            child.addChild(identifier)
            //child.addChild(value)
            subset.addChild(child)
            root.addChild(subset)
            print(xml.xmlString) // Uncomment for debugging
            returnedXML = xml.xmlData
        }
        
        
        // BUILD XML FOR EXTENSION ATTRIBUTE UPDATES
        if xmlAttribute == "extension_attribute" {
            let root = XMLElement(name: xmlDevice!)
            let xml = XMLDocument(rootElement: root)
            let subset = XMLElement(name: "extension_attributes")
            let child = XMLElement(name: "extension_attribute")
            let identifier = XMLElement(name: "id", stringValue: eaID)
            let value = XMLElement(name: "value", stringValue: columnB)
            child.addChild(identifier)
            child.addChild(value)
            subset.addChild(child)
            root.addChild(subset)
            //print(xml.xmlString) // Uncomment for debugging
            returnedXML = xml.xmlData
        }
        
        // BUILD XML FOR iOS AND macOS SITES (do iOS sites work yet?)
        if xmlAttribute == "site" && xmlDevice != "user" {
            let root = XMLElement(name: xmlDevice!)
            let xml = XMLDocument(rootElement: root)
            let subset = XMLElement(name: "general")
            let child = XMLElement(name: "site")
            let identifier = XMLElement(name: xmlExtra!, stringValue: columnB)
            child.addChild(identifier)
            subset.addChild(child)
            root.addChild(subset)
            //print(xml.xmlString) // Uncomment for debugging
            returnedXML = xml.xmlData
        }
        
        // BUILD XML FOR USER SITES
        if xmlAttribute == "site" && xmlDevice == "user" {
            let root = XMLElement(name: xmlDevice!)
            let xml = XMLDocument(rootElement: root)
            let subset = XMLElement(name: "sites")
            let child = XMLElement(name: "site")
            let identifier = XMLElement(name: xmlExtra!, stringValue: columnB)
            child.addChild(identifier)
            subset.addChild(child)
            root.addChild(subset)
            //print(xml.xmlString) // Uncomment for debugging
            returnedXML = xml.xmlData
        }
        
        // BUILD XML FOR ENFORCING DEVICE NAMES
        if xmlAttribute == "name" && xmlDevice == "mobile_device" {
            let root = XMLElement(name: "mobile_device_command")
            let xml = XMLDocument(rootElement: root)
            let command = XMLElement(name: "command", stringValue: "DeviceName")
            let name = XMLElement(name: "device_name", stringValue: columnB)
            let subset = XMLElement(name: "mobile_devices")
            let child = XMLElement(name: "mobile_device")
            let identifier = XMLElement(name: "serial_number", stringValue: columnA)
            child.addChild(identifier)
            subset.addChild(child)
            root.addChild(command)
            root.addChild(name)
            root.addChild(subset)
            //print(xml.xmlString) // Uncomment for debugging
            returnedXML = xml.xmlData
        }
        
        // BUILD XML FOR GENERIC USER UPDATES
        if xmlDevice == "user" && xmlSubset == "" {
            let root = XMLElement(name: "user")
            let xml = XMLDocument(rootElement: root)
            let value = XMLElement(name: xmlAttribute!, stringValue: columnB)
            root.addChild(value)
            //print(xml.xmlString) // Uncomment for debugging
            returnedXML = xml.xmlData
        }
        
        // BUILD XML FOR GENERIC DEVICE UPDATES
        if xmlDevice != "user" && xmlExtra == "" && xmlAttribute != "name" {
            let root = XMLElement(name: xmlDevice!)
            let xml = XMLDocument(rootElement: root)
            let subset = XMLElement(name: xmlSubset!)
            let value = XMLElement(name: xmlAttribute!, stringValue: columnB)
            subset.addChild(value)
            root.addChild(subset)
            print(xml.xmlString) // Uncomment for debugging*/
            returnedXML = xml.xmlData
        }
        return returnedXML!
    }
    
    // BUILD XML FOR GENERIC UPDATES - iOS AND macOS
    public func generalDeviceUpdates(deviceType: String, subsetType: String, attributeType: String, attributeValue: String) -> Data? {
        let root = XMLElement(name: deviceType)
        let xml = XMLDocument(rootElement: root)
        let subset = XMLElement(name: subsetType)
        let value = XMLElement(name: attributeType, stringValue: attributeValue)
        subset.addChild(value)
        root.addChild(subset)
        print(xml.xmlString) // Uncomment for debugging
        return xml.xmlData
    }
    
    // BUILD XML FOR EXTENSION ATTRIBUTES - USER, iOS AND macOS
    public func updateExtensionAttribute(deviceType: String, eaValue: String, eaID: String) -> Data? {
        let root = XMLElement(name: deviceType)
        let xml = XMLDocument(rootElement: root)
        let subset = XMLElement(name: "extension_attributes")
        let child = XMLElement(name: "extension_attribute")
        let identifier = XMLElement(name: "id", stringValue: eaID)
        let value = XMLElement(name: "value", stringValue: eaValue)
        child.addChild(identifier)
        child.addChild(value)
        subset.addChild(child)
        root.addChild(subset)
        //print(xml.xmlString) // Uncomment for debugging
        return xml.xmlData
    }
    
    // BUILD XML FOR SITES - iOS AND macOS
    public func deviceSite(deviceType: String, identifierType: String, identifierValue: String) -> Data? {
        let root = XMLElement(name: deviceType)
        let xml = XMLDocument(rootElement: root)
        let subset = XMLElement(name: "general")
        let child = XMLElement(name: "site")
        let identifier = XMLElement(name: identifierType, stringValue: identifierValue)
        child.addChild(identifier)
        subset.addChild(child)
        root.addChild(subset)
        //print(xml.xmlString) // Uncomment for debugging
        return xml.xmlData
    }
    
    // BUILD XML FOR SITES - USERS
    public func userSite(identifierType: String, identifierValue: String) -> Data? {
        let root = XMLElement(name: "user")
        let xml = XMLDocument(rootElement: root)
        let subset = XMLElement(name: "sites")
        let child = XMLElement(name: "site")
        let identifier = XMLElement(name: identifierType, stringValue: identifierValue)
        child.addChild(identifier)
        subset.addChild(child)
        root.addChild(subset)
        //print(xml.xmlString) // Uncomment for debugging
        return xml.xmlData
    }
    
    // BUILD XML FOR GENERIC UPDATES - USER
    public func generalUserUpdates(attributeType: String, attributeValue: String) -> Data? {
        let root = XMLElement(name: "user")
        let xml = XMLDocument(rootElement: root)
        let value = XMLElement(name: attributeType, stringValue: attributeValue)
        root.addChild(value)
        //print(xml.xmlString) // Uncomment for debugging
        return xml.xmlData
    }
    
    // BUILD XML FOR ENFORCING MOBILE DEVICE NAMES - iOS
    public func enforceName(newName: String, serialNumber: String) -> Data? {
        let root = XMLElement(name: "mobile_device_command")
        let xml = XMLDocument(rootElement: root)
        let command = XMLElement(name: "command", stringValue: "DeviceName")
        let name = XMLElement(name: "device_name", stringValue: newName)
        let subset = XMLElement(name: "mobile_devices")
        let child = XMLElement(name: "mobile_device")
        let identifier = XMLElement(name: "serial_number", stringValue: serialNumber)
        child.addChild(identifier)
        subset.addChild(child)
        root.addChild(command)
        root.addChild(name)
        root.addChild(subset)
        //print(xml.xmlString) // Uncomment for debugging
        return xml.xmlData
    }
}
