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
    var xml = "stuff"
    var formattedEndpoint = ""
    var globalXMLSubsetStart = ""
    var globalXMLSubsetEnd = ""
    var globalXMLAttribute = ""
    var globalXMLExtraStart = ""
    var globalXMLExtraEnd = ""
    
    var xmlSubset = ""
    var xmlAttribute = ""
    var xmlExtras = ""
    
    
    // Generate the XML for updating normal attributes
    public func updateComputer(attribute: String, attributeValue: String, extraIdentifier: String) -> String {
    
        
        // Switches for attributes and subsets
        switch (attribute) {
        case " Device Name" :
            globalXMLSubsetStart = "<general>"
            globalXMLSubsetEnd = "</general>"
            globalXMLAttribute = "name"
            globalXMLExtraStart = ""
            globalXMLExtraEnd = ""
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

        default:
            print("Something Broke")
        }

        
        
        xml =   "<computer>" +
                    "\(globalXMLSubsetStart)" +
                        "<\(globalXMLAttribute)>" +
                            "\(globalXMLExtraStart)\(attributeValue)\(globalXMLExtraEnd)" +
                        "</\(globalXMLAttribute)>" +
                    "\(globalXMLSubsetEnd)" +
                "</computer>"
        //print(xml)

        
        
        return xml
    }
    

    
    // Generate xml for updating a mobile device username (SAMPLE/TEST)
    
    public func macosGeneric(attribute: String, attributeValue: String) -> Data? {

        let root = XMLElement(name: "computer")
        let xml = XMLDocument(rootElement: root)

        
        if xmlExtras == "" {
            let subset = XMLElement(name: xmlSubset)
            let child = XMLElement(name: xmlAttribute, stringValue: attributeValue)
            subset.addChild(child)
            root.addChild(subset)
        } else {
            let subset = XMLElement(name: xmlSubset)
            let extras = XMLElement(name: "stuff", stringValue: attributeValue)
            let child = XMLElement(name: xmlAttribute)
            child.addChild(extras)
            subset.addChild(child)
            root.addChild(subset)
        }
    
        let encodedXML = xml.xmlString.data(using: String.Encoding.utf8)
        print(xml.xmlString)
        return encodedXML
    }
    
    // BUILD XML FOR EXTENSION ATTRIBUTES
    public func updateExtensionAttribute(deviceType: String, eaValue: String, eaID: String) -> String? {
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
        return xml.xmlString
    }
    
    // BUILD XML FOR SITES FOR DEVICES ONLY, USERS WILL BE DIFFERENT
    public func deviceSite(deviceType: String, identifierType: String, identifierValue: String) -> String? {
        let root = XMLElement(name: deviceType)
        let xml = XMLDocument(rootElement: root)
        let subset = XMLElement(name: "general")
        let child = XMLElement(name: "site")
        let identifier = XMLElement(name: identifierType, stringValue: identifierValue)
        child.addChild(identifier)
        subset.addChild(child)
        root.addChild(subset)
        //print(xml.xmlString) // Uncomment for debugging
        return xml.xmlString
    }
    
    // BUILD XML FOR SITES FOR USERS ONLY, DEVICES WILL BE DIFFERENT
    public func userSite(identifierType: String, identifierValue: String) -> String? {
        let root = XMLElement(name: "user")
        let xml = XMLDocument(rootElement: root)
        let subset = XMLElement(name: "sites")
        let child = XMLElement(name: "site")
        let identifier = XMLElement(name: identifierType, stringValue: identifierValue)
        child.addChild(identifier)
        subset.addChild(child)
        root.addChild(subset)
        //print(xml.xmlString) // Uncomment for debugging
        return xml.xmlString
    }
    
    // BUILD XML FOR ENFORCING MOBILE DEVICE NAMES
    public func enforceName(newName: String, serialNumber: String) -> Data? {
        let root = XMLElement(name: "mobile_device_command")
        let xml = XMLDocument(rootElement: root)
        let command = XMLElement(name: "command", stringValue: "DeviceName")
        let name = XMLElement(name: "device_name", stringValue: newName)
        let subset = XMLElement(name: "mobiledevices")
        let child = XMLElement(name: "mobile_device")
        let identifier = XMLElement(name: "serial_number", stringValue: serialNumber)
        child.addChild(identifier)
        subset.addChild(child)
        root.addChild(command)
        root.addChild(name)
        root.addChild(subset)
        print(xml.xmlString) // Uncomment for debugging
        return xml.xmlData
    }
    
}
