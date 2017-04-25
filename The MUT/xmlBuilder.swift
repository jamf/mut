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
    var xml: Data?
    
    // CHOOSE THE CORRECT XML BUILDING FUNCTION BASED ON DROPDOWNS
    public func generateXML(popDevice: String, popIdentifier: String, popAttribute: String, popEAID: String, newValue: String, jssURL: String) -> Data? {
        switch (popAttribute) {
            
        // UPDATE EXTENSION ATTRIBUTES
        case " Extension Attribute" :
            print(" Extension Attribute")
            switch (popDevice) {
            case " iOS Devices" :
                xml = updateExtensionAttribute(deviceType: "mobile_device", eaValue: newValue, eaID: popEAID)
            case " MacOS Devices" :
                xml = updateExtensionAttribute(deviceType: "computer", eaValue: newValue, eaID: popEAID)
            case " Users" :
                xml = updateExtensionAttribute(deviceType: "user", eaValue: newValue, eaID: popEAID)
            default :
                break
            }
            
        // UPDATE SITE BY NAME
        case " Site by Name" :
            print(" Site by Name")
            switch (popDevice) {
            case " iOS Devices" :
                xml = deviceSite(deviceType: "mobile_device", identifierType: "name", identifierValue: newValue)
            case " MacOS Devices" :
                xml = deviceSite(deviceType: "computer", identifierType: "name", identifierValue: newValue)
            case " Users" :
                xml = userSite(identifierType: "name", identifierValue: newValue)
            default :
                break
            }
            
        // UPDATE SITE BY ID
        case " Site by ID" :
            print(" Site by ID")
            switch (popDevice) {
            case " iOS Devices" :
                xml = deviceSite(deviceType: "mobile_device", identifierType: "id", identifierValue: newValue)
            case " MacOS Devices" :
                xml = deviceSite(deviceType: "computer", identifierType: "id", identifierValue: newValue)
            case " Users" :
                xml = userSite(identifierType: "id", identifierValue: newValue)
            default :
                break
            }
            
        default :
            break
        }
        
        
        //let encodedXML = xml.data(using: String.Encoding.utf8)
        return xml
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
