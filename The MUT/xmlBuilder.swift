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
    // Globally declaring the xml variable to allow the various functions to populate it
    var xml: XMLDocument?
    
    // MARK: - URL Creation based on dropdowns
    
    /* ===
    These various functions are called when the HTTP Requests are made, based on the dropdown values selected
    I used to have these all in one big function and split them out through if/then statements here, but
    it became rather difficult to add new functionality such as the static group population.
    === */
    
    // Create the URL for generic updates, such as asset tag and username
    public func createPUTURL(url: String, endpoint: String, idType: String, columnA: String) -> URL {
        let stringURL = "\(url)\(endpoint)/\(idType)/\(columnA)"
        let urlwithPercentEscapes = stringURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        let encodedURL = NSURL(string: urlwithPercentEscapes!)
        //print(urlwithPercentEscapes!) // Uncomment for debugging
        return encodedURL! as URL
    }
    
    // Create the URL for populating macOS Static Groups
    public func createMacGroupURL(url: String, columnB: String) -> URL {
        let stringURL = "\(url)computergroups/id/\(columnB)"
        let urlwithPercentEscapes = stringURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        let encodedURL = NSURL(string: urlwithPercentEscapes!)
        //print(urlwithPercentEscapes!) // Uncomment for debugging
        return encodedURL! as URL
    }
    
    // Create the URL for populating iOS Static Groups
    public func createiOSGroupURL(url: String, columnB: String) -> URL {
        let stringURL = "\(url)mobiledevicegroups/id/\(columnB)"
        let urlwithPercentEscapes = stringURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        let encodedURL = NSURL(string: urlwithPercentEscapes!)
        //print(urlwithPercentEscapes!) // Uncomment for debugging
        return encodedURL! as URL
    }
    
    // Create the URL for populating User Static Groups
    public func createUserGroupURL(url: String, columnB: String) -> URL {
        let stringURL = "\(url)usergroups/id/\(columnB)"
        let urlwithPercentEscapes = stringURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        let encodedURL = NSURL(string: urlwithPercentEscapes!)
        //print(urlwithPercentEscapes!) // Uncomment for debugging
        return encodedURL! as URL
    }
    
    // Create the URL for generating MDM commands via POST to enforce mobile device name
    public func createPOSTURL(url: String) -> URL {
        let stringURL = "\(url)mobiledevicecommands/command/DeviceName"
        let encodedURL = NSURL(string: stringURL)
        //print(urlwithPercentEscapes!) // Uncomment for debugging
        return encodedURL! as URL
    }
    
    // Create the URL that is used to verify the credentials against reading activation code
    public func createGETURL(url: String) -> URL {
        let stringURL = "\(url)activationcode"
        let encodedURL = NSURL(string: stringURL)
        //print(urlwithPercentEscapes!) // Uncomment for debugging
        return encodedURL! as URL
    }
    
    
    // MARK: - XML Creation based on dropdowns
    
    /* ===
     This section will first use an anonymous hash/tuple to "translate" the human readable dropdowns into
     a more computer readable format. 
     
     The values here typically directly translate into what the XML expects to see on a PUT or POST
     however some are simply identifiable placeholders. The logic statements below help to determine which XML format
     should be built and used for the upload, depending on what is being done. The various methods of building the xml
     are mostly due to how different various JSS API endpoints behave, and how the xml format differs between them.
     For example, sites are under the general subset, in a site sub-subset for ios and mac, but simply in the sites subset for users
    === */
    
    public func createXML(popIdentifier: String, popDevice: String, popAttribute: String, eaID: String, columnB: String, columnA: String) -> Data {
        var returnedXML: Data?
        
        let xmlDevice = ["macOS Devices": "computer", "iOS Devices": "mobile_device", "Users": "user"][popDevice]
        
        let xmlSubset = ["Asset Tag": "general", "Barcode 1": "general", "Barcode 2": "general", "Device Name": "general", "Site by ID": "general", "Site by Name": "general", "Username": "location", "Full Name": "location", "Email": "location", "Position": "location", "Department": "location", "Building": "location", "Room": "location", "Extension Attribute": "extension_attributes", "User's Username": "", "User's Full Name": "", "Email Address": "", "User's Position": "", "Phone Number": "", "User's Site by ID": "sites", "User's Site by Name": "sites", "User Extension Attribute": "extension_attributes", "ADD TO macOS Static Group": "computer_additions", "ADD TO iOS Static Group": "mobile_device_additions","ADD TO User Static Group": "user_additions","REMOVE FROM macOS Static Group": "computer_deletions", "REMOVE FROM iOS Static Group": "mobile_device_deletions","REMOVE FROM User Static Group": "user_deletions","PO Number": "purchasing", "Vendor": "purchasing", "PO Date": "purchasing", "Warranty Expires": "purchasing", "Lease Expires": "purchasing", "LDAP Server": "ldap_server", "tvOS AirPlay Password": "general" ][popAttribute]
        
        let xmlAttribute = ["Asset Tag": "asset_tag", "Barcode 1": "barcode_1", "Barcode 2": "barcode_2","Device Name": "name", "Site by ID": "site", "Site by Name": "site", "Username": "username", "Full Name": "real_name", "Email": "email_address", "Position": "position", "Department": "department", "Building": "building", "Room": "room", "Extension Attribute": "extension_attribute", "User's Username": "name", "User's Full Name": "full_name", "Email Address": "email", "User's Position": "position", "Phone Number": "phone_number", "User's Site by ID": "site", "User's Site by Name": "site", "User Extension Attribute": "extension_attribute", "ADD TO macOS Static Group": "computer_group", "REMOVE FROM macOS Static Group": "computer_group", "ADD TO iOS Static Group": "mobile_device_group","REMOVE FROM iOS Static Group": "mobile_device_group","ADD TO User Static Group": "user_group", "REMOVE FROM User Static Group": "user_group", "PO Number":"po_number", "Vendor": "vendor","PO Date": "po_date", "Warranty Expires": "warranty_expires", "Lease Expires": "lease_expires", "LDAP Server": "ldap_server", "tvOS AirPlay Password": "airplay_password" ][popAttribute]
        
        let xmlExtra = ["Asset Tag": "", "Barcode 1": "", "Barcode 2": "", "Device Name": "", "Site by ID": "id", "Site by Name": "name", "Username": "", "Full Name": "", "Email": "", "Position": "", "Department": "", "Building": "", "Room": "", "Extension Attribute": "value", "User's Username": "", "User's Full Name": "", "Email Address": "", "User's Position": "", "Phone Number": "", "User's Site by ID": "id", "User's Site by Name": "name", "User Extension Attribute": "value", "ADD TO macOS Static Group": "computer", "ADD TO iOS Static Group": "mobile_device","ADD TO User Static Group": "user", "REMOVE FROM macOS Static Group": "computer", "REMOVE FROM iOS Static Group": "mobile_device","REMOVE FROM User Static Group": "user", "PO Number":"", "Vendor": "","PO Date": "", "Warranty Expires": "", "Lease Expires": "", "LDAP Server": "ldap_server", "tvOS AirPlay Password": "" ][popAttribute]
        
        // BUILD XML FOR DEVICE STATIC GROUP
        if xmlAttribute == "computer_group" || xmlAttribute == "mobile_device_group" {
            let root = XMLElement(name: xmlAttribute!)
            let xml = XMLDocument(rootElement: root)
            let subset = XMLElement(name: xmlSubset!)
            let child = XMLElement(name: xmlExtra!)
            var identifier = XMLElement(name: "null", stringValue: columnA)
            if popIdentifier == "serialnumber" {
                identifier = XMLElement(name: "serial_number", stringValue: columnA)
            }
            if popIdentifier == "id" {
                identifier = XMLElement(name: "id", stringValue: columnA)
            }
            child.addChild(identifier)
            subset.addChild(child)
            root.addChild(subset)
            //print(xml.xmlString) // Uncomment for debugging
            returnedXML = xml.xmlData
        }
        
        // BUILD XML FOR USER STATIC GROUP
        if xmlAttribute == "user_group" {
            let root = XMLElement(name: xmlAttribute!)
            let xml = XMLDocument(rootElement: root)
            let subset = XMLElement(name: xmlSubset!)
            let child = XMLElement(name: xmlExtra!)
            var identifier = XMLElement(name: "null", stringValue: columnA)
            if popIdentifier == "name" {
                identifier = XMLElement(name: "username", stringValue: columnA)
            }
            if popIdentifier == "id" {
                identifier = XMLElement(name: "id", stringValue: columnA)
            }
            child.addChild(identifier)
            subset.addChild(child)
            root.addChild(subset)
            //print(xml.xmlString) // Uncomment for debugging
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
        
        // BUILD XML FOR iOS AND macOS SITES
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
        
        // BUILD XML FOR LDAP SERVER USER UPDATES
        if xmlDevice == "user" && xmlSubset == "ldap_server" {
            let root = XMLElement(name: "user")
            let xml = XMLDocument(rootElement: root)
            let subset = XMLElement(name: xmlSubset!)
            let value = XMLElement(name: "id", stringValue: columnB)
            subset.addChild(value)
            root.addChild(subset)
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
            //print(xml.xmlString) // Uncomment for debugging*/
            returnedXML = xml.xmlData
        }
        
        // BUILD XML FOR COMPUTER NAME UPDATES (TODO: Clean up the logic here)
        if xmlDevice == "computer" && xmlExtra == "" && xmlAttribute == "name" {
            let root = XMLElement(name: xmlDevice!)
            let xml = XMLDocument(rootElement: root)
            let subset = XMLElement(name: xmlSubset!)
            let value = XMLElement(name: xmlAttribute!, stringValue: columnB)
            subset.addChild(value)
            root.addChild(subset)
            //print(xml.xmlString) // Uncomment for debugging*/
            returnedXML = xml.xmlData
        }
        return returnedXML!
    }
}
