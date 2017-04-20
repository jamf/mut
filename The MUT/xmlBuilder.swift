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
            globalXMLExtraStart = "<id>\(extraIdentifier)</id><value>"
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
            globalXMLExtraStart = "<id>\(extraIdentifier)</id><value>"
            globalXMLExtraEnd = "</value>"
        //print("User EA")
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
    
    // Generate the XML for enforcing mobile device names
    public func enforceName(newName: String, serialNumber: String) -> Data? {
        let xml =   "<mobile_device_command>" +
                        "<command>DeviceName</command>" +
                        "<device_name>\(newName)</device_name>" +
                        "<mobile_devices>" +
                            "<mobile_device>" +
                                "<serial_number>\(serialNumber)</serial_number>" +
                            "</mobile_device>" +
                        "</mobile_devices>" +
                    "</mobile_device_command>"
        let encodedXML = xml.data(using: String.Encoding.utf8)
        print(xml)
        return encodedXML
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
    
    public func macosExtensionAttribute(eaValue: String, eaID: String) -> Data? {
        
        let root = XMLElement(name: "computer")
        let xml = XMLDocument(rootElement: root)
        
        let subset = XMLElement(name: "extension_attributes")
        let child = XMLElement(name: "extension_attribute")
        let identifier = XMLElement(name: "id", stringValue: eaID)
        let value = XMLElement(name: "value", stringValue: eaValue)

        child.addChild(identifier)
        child.addChild(value)
        subset.addChild(child)
        root.addChild(subset)
        
        let encodedXML = xml.xmlString.data(using: String.Encoding.utf8)
        print(xml.xmlString)
        return encodedXML
    }
    
    
    
}
