//
//  xmlBuilder.swift
//  The MUT v5
//
//  Created by Michael Levenick on 5/24/19.
//  Copyright © 2019 Levenick Enterprises, LLC. All rights reserved.
//

import Cocoa
import Foundation

public class xmlManager {
    // Globally declaring the xml variable to allow the various functions to populate it
    var xml: XMLDocument?
    let removalValue = "CLEAR!"
    let xmlDefaults = UserDefaults.standard


    public func userObject(username: String, full_name: String, email_address: String, phone_number: String, position: String, ldap_server: String, ea_ids: [String], ea_values: [String], site_ident: String, managedAppleID: String) -> Data {

        // User Object update XML Creation:

        // Variables needed for the rest of the XML Generation
        let root = XMLElement(name: "user")
        let xml = XMLDocument(rootElement: root)

        // Username
        let usernameElement = XMLElement(name: "name", stringValue: username)
        populateElement(variableToCheck: username, elementName: "name", elementToAdd: usernameElement, whereToAdd: root)
        
        // Full Name
        let fullNameElement = XMLElement(name: "full_name", stringValue: full_name)
        populateElement(variableToCheck: full_name, elementName: "full_name", elementToAdd: fullNameElement, whereToAdd: root)

        // Email Address
        let emailElement = XMLElement(name: "email", stringValue: email_address)
        let emailAddressElement = XMLElement(name: "email_address", stringValue: email_address)
        populateElement(variableToCheck: email_address, elementName: "email", elementToAdd: emailElement, whereToAdd: root)
        populateElement(variableToCheck: email_address, elementName: "email_address", elementToAdd: emailAddressElement, whereToAdd: root)

        // Phone Number
        let phoneNumberElement = XMLElement(name: "phone_number", stringValue: phone_number)
        populateElement(variableToCheck: phone_number, elementName: "phone_number", elementToAdd: phoneNumberElement, whereToAdd: root)

        // Position
        let positionElement = XMLElement(name: "position", stringValue: position)
        populateElement(variableToCheck: position, elementName: "position", elementToAdd: positionElement, whereToAdd: root)
        
        // Managed Apple ID
        let managedAppleIDElement = XMLElement(name: "managed_apple_id", stringValue: managedAppleID)
        populateElement(variableToCheck: managedAppleID, elementName: "managed_apple_id", elementToAdd: managedAppleIDElement, whereToAdd: root)

        // LDAP Server
        let ldapServerElement = XMLElement(name: "ldap_server")
        var ldapServerIDElement = XMLElement(name: "id", stringValue: ldap_server) // Set LDAP Server ID to -1 to unassign from all.
        
        if ldap_server == removalValue {
            ldapServerIDElement = XMLElement(name: "id", stringValue: "-1")
            ldapServerElement.addChild(ldapServerIDElement)
            root.addChild(ldapServerElement)
        } else if ldap_server != "" {
            ldapServerElement.addChild(ldapServerIDElement)
            root.addChild(ldapServerElement)
        }

        // Site
        let sitesElement = XMLElement(name: "sites")
        let siteElement = XMLElement(name: "site")
        var siteIDElement = XMLElement(name: "id", stringValue: site_ident)
        if site_ident == removalValue {
            siteIDElement = XMLElement(name: "id", stringValue: "-1")
            siteElement.addChild(siteIDElement)
            sitesElement.addChild(siteElement)
            root.addChild(sitesElement)
        } else if site_ident != "" {
            if site_ident.isInt {
                siteIDElement = XMLElement(name: "id", stringValue: site_ident)
            } else {
                siteIDElement = XMLElement(name: "name", stringValue: site_ident)
            }
            siteElement.addChild(siteIDElement)
            sitesElement.addChild(siteElement)
            root.addChild(sitesElement)
        }


        // Extension Attributes
        let extensionAttributesElement = XMLElement(name: "extension_attributes")
        
        if ea_values.count > 0 {
            // Loop through the EA values, adding them to the EA node
            for i in 0...(ea_ids.count - 1 ) {

                // Extension Attributes
                if ea_values[i] == removalValue {
                    let currentExtensionAttributesElement = XMLElement(name: "extension_attribute")
                    currentExtensionAttributesElement.addChild(XMLElement(name: "id", stringValue: ea_ids[i]))
                    currentExtensionAttributesElement.addChild(XMLElement(name: "value", stringValue: ""))
                    extensionAttributesElement.addChild(currentExtensionAttributesElement)
                } else if ea_values[i] != "" {
                    let currentExtensionAttributesElement = XMLElement(name: "extension_attribute")
                    currentExtensionAttributesElement.addChild(XMLElement(name: "id", stringValue: ea_ids[i]))
                    currentExtensionAttributesElement.addChild(XMLElement(name: "value", stringValue: ea_values[i]))
                    extensionAttributesElement.addChild(currentExtensionAttributesElement)
                }
            }

            // Add the EA subset to the root element
            root.addChild(extensionAttributesElement)
        }


        // Print the XML
        NSLog(xml.debugDescription) // Uncomment for debugging
        return xml.xmlData
    }


    public func iosObject(displayName: String, assetTag: String, username: String, full_name: String, email_address: String, phone_number: String, position: String, department: String, building: String, room: String, poNumber: String, vendor: String, purchasePrice: String, poDate: String, warrantyExpires: String, leaseExpires: String, ea_ids: [String], ea_values: [String], site_ident: String, airplayPassword: String) -> Data {

        // iOS Object update XML Creation:
        
        let generalStuff = displayName + assetTag + airplayPassword + site_ident
        let locationStuff = username + full_name + email_address + phone_number + position + department + building + room
        let purchasingStuff = poNumber + vendor + poDate + warrantyExpires + leaseExpires + purchasePrice

        // Variables needed for the rest of the XML Generation
        let root = XMLElement(name: "mobile_device")
        let xml = XMLDocument(rootElement: root)
        let general = XMLElement(name: "general")
        let location = XMLElement(name: "location")
        let purchasing = XMLElement(name: "purchasing")
        
        
        // ----------------------
        // DEVICE NAME
        // ----------------------

        let displayNameElement = XMLElement(name: "display_name", stringValue: displayName)
        let deviceNameElement = XMLElement(name: "device_name", stringValue: displayName)
        let nameElement = XMLElement(name: "name", stringValue: displayName)

        if displayName != "" {
            general.addChild(displayNameElement)
            general.addChild(deviceNameElement)
            general.addChild(nameElement)
        }


        // ----------------------
        // GENERAL ATTRIBUTES
        // ----------------------
        
        // Asset Tag
        let assetTagElement = XMLElement(name: "asset_tag", stringValue: assetTag)
        populateElement(variableToCheck: assetTag, elementName: "asset_tag", elementToAdd: assetTagElement, whereToAdd: general)
        
        let airplayPasswordElement = XMLElement(name: "airplay_password", stringValue: airplayPassword)
        populateElement(variableToCheck: airplayPassword, elementName: "airplay_password", elementToAdd: airplayPasswordElement, whereToAdd: general)

        // Site
        let siteElement = XMLElement(name: "site")
        var siteIDElement = XMLElement(name: "id", stringValue: site_ident)
        if site_ident == removalValue {
            siteIDElement = XMLElement(name: "id", stringValue: "-1")
            siteElement.addChild(siteIDElement)
            general.addChild(siteElement)
        } else if site_ident != "" {
            if site_ident.isInt {
                siteIDElement = XMLElement(name: "id", stringValue: site_ident)
            } else {
                siteIDElement = XMLElement(name: "name", stringValue: site_ident)
            }
            siteElement.addChild(siteIDElement)
            general.addChild(siteElement)
        }
        
        // ----------------------
        // LOCATION ATTRIBUTES
        // ----------------------
        
        // Username
        let usernameElement = XMLElement(name: "username", stringValue: username)
        populateElement(variableToCheck: username, elementName: "username", elementToAdd: usernameElement, whereToAdd: location)
        
        // Real Name
        let realnameElement = XMLElement(name: "realname", stringValue: full_name)
        let real_nameElement = XMLElement(name: "real_name", stringValue: full_name)
        populateElement(variableToCheck: full_name, elementName: "realname", elementToAdd: realnameElement, whereToAdd: location)
        populateElement(variableToCheck: full_name, elementName: "real_name", elementToAdd: real_nameElement, whereToAdd: location)

        
        // Email Address
        let emailAddressElement = XMLElement(name: "email_address", stringValue: email_address)
        populateElement(variableToCheck: email_address, elementName: "email_address", elementToAdd: emailAddressElement, whereToAdd: location)
        
        // Position
        let positionElement = XMLElement(name: "position", stringValue: position)
        populateElement(variableToCheck: position, elementName: "position", elementToAdd: positionElement, whereToAdd: location)
        
        // Phone Number
        let phoneElement = XMLElement(name: "phone", stringValue: phone_number)
        let phoneNumberElement = XMLElement(name: "phone_number", stringValue: phone_number)
        populateElement(variableToCheck: phone_number, elementName: "phone", elementToAdd: phoneElement, whereToAdd: location)
        populateElement(variableToCheck: phone_number, elementName: "phone_number", elementToAdd: phoneNumberElement, whereToAdd: location)
        
        // Department
        let departmentElement = XMLElement(name: "department", stringValue: department)
        populateElement(variableToCheck: department, elementName: "department", elementToAdd: departmentElement, whereToAdd: location)
        
        // Building
        let buildingElement = XMLElement(name: "building", stringValue: building)
        populateElement(variableToCheck: building, elementName: "building", elementToAdd: buildingElement, whereToAdd: location)
        
        // Room
        let roomElement = XMLElement(name: "room", stringValue: room)
        populateElement(variableToCheck: room, elementName: "room", elementToAdd: roomElement, whereToAdd: location)
        
        // ----------------------
        // PURCHASING ATTRIBUTES
        // ----------------------
        
        // PO Number
        let poNumberElement = XMLElement(name: "po_number", stringValue: poNumber)
        populateElement(variableToCheck: poNumber, elementName: "po_number", elementToAdd: poNumberElement, whereToAdd: purchasing)
        
        // Vendor
        let vendorElement = XMLElement(name: "vendor", stringValue: vendor)
        populateElement(variableToCheck: vendor, elementName: "vendor", elementToAdd: vendorElement, whereToAdd: purchasing)
        
        // Purchase Price
        let purchasePriceElement = XMLElement(name: "purchase_price", stringValue: purchasePrice)
        populateElement(variableToCheck: purchasePrice, elementName: "purchase_price", elementToAdd: purchasePriceElement, whereToAdd: purchasing)
        
        // PO Date
        let poDateElement = XMLElement(name: "po_date", stringValue: poDate)
        populateElement(variableToCheck: poDate, elementName: "po_date", elementToAdd: poDateElement, whereToAdd: purchasing)
        
        // Warranty Expires
        let warrantyExpiresElement = XMLElement(name: "warranty_expires", stringValue: warrantyExpires)
        populateElement(variableToCheck: warrantyExpires, elementName: "warranty_expires", elementToAdd: warrantyExpiresElement, whereToAdd: purchasing)
        
        // Lease Expires
        let leaseExpiresElement = XMLElement(name: "lease_expires", stringValue: leaseExpires)
        populateElement(variableToCheck: leaseExpires, elementName: "lease_expires", elementToAdd: leaseExpiresElement, whereToAdd: purchasing)
        
        // ----------------------
        // EXTENSION ATTRIBUTES
        // ----------------------
        
        let extensionAttributesElement = XMLElement(name: "extension_attributes")

        if ea_values.count > 0 {
            // Loop through the EA values, adding them to the EA node
            for i in 0...(ea_ids.count - 1 ) {

                // Extension Attributes
                if ea_values[i] == removalValue {
                    let currentExtensionAttributesElement = XMLElement(name: "extension_attribute")
                    currentExtensionAttributesElement.addChild(XMLElement(name: "id", stringValue: ea_ids[i]))
                    currentExtensionAttributesElement.addChild(XMLElement(name: "value", stringValue: ""))
                    extensionAttributesElement.addChild(currentExtensionAttributesElement)
                } else if ea_values[i] != "" {
                    let currentExtensionAttributesElement = XMLElement(name: "extension_attribute")
                    currentExtensionAttributesElement.addChild(XMLElement(name: "id", stringValue: ea_ids[i]))
                    currentExtensionAttributesElement.addChild(XMLElement(name: "value", stringValue: ea_values[i]))
                    extensionAttributesElement.addChild(currentExtensionAttributesElement)
                }
            }
            root.addChild(extensionAttributesElement)
        }
        
        if generalStuff != "" {
            root.addChild(general)
        }
        if locationStuff != "" {
            root.addChild(location)
        }
        if purchasingStuff != "" {
            root.addChild(purchasing)
        }

        // Print the XML
        NSLog(xml.debugDescription) // Uncomment for debugging
        return xml.xmlData
    }
    
    public func macosObject(displayName: String, assetTag: String, barcode1: String, barcode2: String, username: String, full_name: String, email_address: String, phone_number: String, position: String, department: String, building: String, room: String, poNumber: String, vendor: String, purchasePrice: String, poDate: String, warrantyExpires: String, leaseExpires: String, ea_ids: [String], ea_values: [String], site_ident: String) -> Data {
        
        // macOS Object update XML Creation:
        
        let generalStuff = displayName + assetTag + barcode1 + barcode2 + site_ident
        let locationStuff = username + full_name + email_address + phone_number + position + department + building + room
        let purchasingStuff = poNumber + vendor + purchasePrice + poDate + warrantyExpires + leaseExpires
        
        // Variables needed for the rest of the XML Generation
        let root = XMLElement(name: "computer")
        let xml = XMLDocument(rootElement: root)
        let general = XMLElement(name: "general")
        let location = XMLElement(name: "location")
        let purchasing = XMLElement(name: "purchasing")
        
        // ----------------------
        // GENERAL ATTRIBUTES
        // ----------------------
        
        // Device Name
        let deviceNameElement = XMLElement(name: "name", stringValue: displayName)
        populateElement(variableToCheck: displayName, elementName: "name", elementToAdd: deviceNameElement, whereToAdd: general)
        
        // Asset Tag
        let assetTagElement = XMLElement(name: "asset_tag", stringValue: assetTag)
        populateElement(variableToCheck: assetTag, elementName: "asset_tag", elementToAdd: assetTagElement, whereToAdd: general)
        
        // Barcode 1
        let barcode1Element = XMLElement(name: "barcode_1", stringValue: barcode1)
        populateElement(variableToCheck: barcode1, elementName: "barcode_1", elementToAdd: barcode1Element, whereToAdd: general)
        
        // Barcode 2
        let barcode2Element = XMLElement(name: "barcode_2", stringValue: barcode2)
        populateElement(variableToCheck: barcode2, elementName: "barcode_2", elementToAdd: barcode2Element, whereToAdd: general)

        // Site
        let siteElement = XMLElement(name: "site")
        var siteIDElement = XMLElement(name: "id", stringValue: site_ident)
        if site_ident == removalValue {
            siteIDElement = XMLElement(name: "id", stringValue: "-1")
            siteElement.addChild(siteIDElement)
            general.addChild(siteElement)
        } else if site_ident != "" {
            if site_ident.isInt {
                siteIDElement = XMLElement(name: "id", stringValue: site_ident)
            } else {
                siteIDElement = XMLElement(name: "name", stringValue: site_ident)
            }
            siteElement.addChild(siteIDElement)
            general.addChild(siteElement)
        }
        
        // ----------------------
        // LOCATION ATTRIBUTES
        // ----------------------
        
        // Username
        let usernameElement = XMLElement(name: "username", stringValue: username)
        populateElement(variableToCheck: username, elementName: "username", elementToAdd: usernameElement, whereToAdd: location)
        
        // Real Name
        let realnameElement = XMLElement(name: "realname", stringValue: full_name)
        let real_nameElement = XMLElement(name: "real_name", stringValue: full_name)
        populateElement(variableToCheck: full_name, elementName: "realname", elementToAdd: realnameElement, whereToAdd: location)
        populateElement(variableToCheck: full_name, elementName: "real_name", elementToAdd: real_nameElement, whereToAdd: location)
        
        
        // Email Address
        let emailAddressElement = XMLElement(name: "email_address", stringValue: email_address)
        populateElement(variableToCheck: email_address, elementName: "email_address", elementToAdd: emailAddressElement, whereToAdd: location)
        
        // Position
        let positionElement = XMLElement(name: "position", stringValue: position)
        populateElement(variableToCheck: position, elementName: "position", elementToAdd: positionElement, whereToAdd: location)
        
        // Phone Number
        let phoneElement = XMLElement(name: "phone", stringValue: phone_number)
        let phoneNumberElement = XMLElement(name: "phone_number", stringValue: phone_number)
        populateElement(variableToCheck: phone_number, elementName: "phone", elementToAdd: phoneElement, whereToAdd: location)
        populateElement(variableToCheck: phone_number, elementName: "phone_number", elementToAdd: phoneNumberElement, whereToAdd: location)
        
        // Department
        let departmentElement = XMLElement(name: "department", stringValue: department)
        populateElement(variableToCheck: department, elementName: "department", elementToAdd: departmentElement, whereToAdd: location)
        
        // Building
        let buildingElement = XMLElement(name: "building", stringValue: building)
        populateElement(variableToCheck: building, elementName: "building", elementToAdd: buildingElement, whereToAdd: location)
        
        // Room
        let roomElement = XMLElement(name: "room", stringValue: room)
        populateElement(variableToCheck: room, elementName: "room", elementToAdd: roomElement, whereToAdd: location)
        
        // ----------------------
        // PURCHASING ATTRIBUTES
        // ----------------------
        
        // PO Number
        let poNumberElement = XMLElement(name: "po_number", stringValue: poNumber)
        populateElement(variableToCheck: poNumber, elementName: "po_number", elementToAdd: poNumberElement, whereToAdd: purchasing)
        
        // Vendor
        let vendorElement = XMLElement(name: "vendor", stringValue: vendor)
        populateElement(variableToCheck: vendor, elementName: "vendor", elementToAdd: vendorElement, whereToAdd: purchasing)
        
        // Purchase Price
        let purchasePriceElement = XMLElement(name: "purchase_price", stringValue: purchasePrice)
        populateElement(variableToCheck: purchasePrice, elementName: "purchase_price", elementToAdd: purchasePriceElement, whereToAdd: purchasing)
        
        // PO Date
        let poDateElement = XMLElement(name: "po_date", stringValue: poDate)
        populateElement(variableToCheck: poDate, elementName: "po_date", elementToAdd: poDateElement, whereToAdd: purchasing)
        
        // Warranty Expires
        let warrantyExpiresElement = XMLElement(name: "warranty_expires", stringValue: warrantyExpires)
        populateElement(variableToCheck: warrantyExpires, elementName: "warranty_expires", elementToAdd: warrantyExpiresElement, whereToAdd: purchasing)
        
        // Lease Expires
        let leaseExpiresElement = XMLElement(name: "lease_expires", stringValue: leaseExpires)
        populateElement(variableToCheck: leaseExpires, elementName: "lease_expires", elementToAdd: leaseExpiresElement, whereToAdd: purchasing)
        
        // ----------------------
        // EXTENSION ATTRIBUTES
        // ----------------------
        
        let extensionAttributesElement = XMLElement(name: "extension_attributes")
        
        if ea_values.count > 0 {
            // Loop through the EA values, adding them to the EA node
            for i in 0...(ea_ids.count - 1 ) {
                
                // Extension Attributes
                if ea_values[i] == removalValue {
                    let currentExtensionAttributesElement = XMLElement(name: "extension_attribute")
                    currentExtensionAttributesElement.addChild(XMLElement(name: "id", stringValue: ea_ids[i]))
                    currentExtensionAttributesElement.addChild(XMLElement(name: "value", stringValue: ""))
                    extensionAttributesElement.addChild(currentExtensionAttributesElement)
                } else if ea_values[i] != "" {
                    let currentExtensionAttributesElement = XMLElement(name: "extension_attribute")
                    currentExtensionAttributesElement.addChild(XMLElement(name: "id", stringValue: ea_ids[i]))
                    currentExtensionAttributesElement.addChild(XMLElement(name: "value", stringValue: ea_values[i]))
                    extensionAttributesElement.addChild(currentExtensionAttributesElement)
                }
            }
            root.addChild(extensionAttributesElement)
        }
        
        if generalStuff != "" {
            root.addChild(general)
        }
        if locationStuff != "" {
            root.addChild(location)
        }
        if purchasingStuff != "" {
            root.addChild(purchasing)
        }
        
        // Print the XML
        NSLog(xml.debugDescription) // Uncomment for debugging
        return xml.xmlData
    }

    public func enforceName(deviceName: String, serial_number: String) -> Data {

        // User Object update XML Creation:

        // Example of the XML that is generated by this function
        /*
         <mobile_device_command>
             <command>DeviceName</command>
             <device_name>New API Name</device_name>
             <mobile_devices>
                 <mobile_device>
                    <serial_number>DJ6PK03TFFCJ</serial_number>
                 </mobile_device>
             </mobile_devices>
         </mobile_device_command>
         */

        // Variables needed for the rest of the XML Generation
        let root = XMLElement(name: "mobile_device_command")
        let xml = XMLDocument(rootElement: root)

        // Command
        let commandElement = XMLElement(name: "command", stringValue: "DeviceName")
        root.addChild(commandElement)

        // Device Name
        let deviceNameElement = XMLElement(name: "device_name", stringValue: deviceName)
        root.addChild(deviceNameElement)

        // Mobile Device
        let mobileDevicesElement = XMLElement(name: "mobile_devices")
        let mobileDeviceElement = XMLElement(name: "mobile_device")
        let serialNumberElement = XMLElement(name: "serial_number", stringValue: serial_number)

        mobileDeviceElement.addChild(serialNumberElement)
        mobileDevicesElement.addChild(mobileDeviceElement)
        root.addChild(mobileDevicesElement)

        // Print the XML
        NSLog(xml.debugDescription) // Uncomment for debugging
        return xml.xmlData
    }

    public func staticGroup(appendReplaceRemove: String, objectType: String, identifiers: [String]) -> Data {

        // Static Group XML Creation:

        // Example of the XML that is generated by this function
        /*
         <computer_group>
             <is_smart>false</is_smart>
             <computers>
                 <computer>
                    <serial_number/>
                 </computer>
                 <computer>
                    <serial_number/>
                 </computer>
             </computers>
         </computer_group>
         */

        if objectType == "computers" {
            // Variables needed for the rest of the XML Generation
            let root = XMLElement(name: "computer_group")
            let xml = XMLDocument(rootElement: root)
            let isSmartElement = XMLElement(name: "is_smart", stringValue: "false")
            var computersElement = XMLElement(name: "computers")

            if appendReplaceRemove == "append" {
                computersElement = XMLElement(name: "computer_additions")
                //computersElement = XMLElement(name: "computer_additions")
            }
            if appendReplaceRemove == "replace" {
                computersElement = XMLElement(name: "computers")
                //computersElement = XMLElement(name: "computers")
            }
            if appendReplaceRemove == "remove" {
                computersElement = XMLElement(name: "computer_deletions")
                //computersElement = XMLElement(name: "computer_deletions")
            }

            // Loop
            for i in 0...(identifiers.count - 1){
                let computerElement = XMLElement(name: "computer")
                let identifier = identifiers[i]
                if identifier.isInt {
                    computerElement.addChild(XMLElement(name: "id", stringValue: identifier.trimmingCharacters(in: CharacterSet.whitespaces)))
                } else {
                    computerElement.addChild(XMLElement(name: "serial_number", stringValue: identifier.trimmingCharacters(in: CharacterSet.whitespaces)))
                }
                computersElement.addChild(computerElement)
            }
            root.addChild(isSmartElement)
            root.addChild(computersElement)
            return xml.xmlData
        }

        if objectType == "mobiledevices" {
            // Variables needed for the rest of the XML Generation
            let root = XMLElement(name: "mobile_device_group")
            let xml = XMLDocument(rootElement: root)
            let isSmartElement = XMLElement(name: "is_smart", stringValue: "false")
            var devicesElement = XMLElement(name: "mobile_devices")

            if appendReplaceRemove == "append" {
                devicesElement = XMLElement(name: "mobile_device_additions")
            }
            if appendReplaceRemove == "replace" {
                devicesElement = XMLElement(name: "mobile_devices")
            }
            if appendReplaceRemove == "remove" {
                devicesElement = XMLElement(name: "mobile_device_deletions")
            }

            // Loop
            for i in 0...(identifiers.count - 1){
                let deviceElement = XMLElement(name: "mobile_device")
                let identifier = identifiers[i]
                if identifier.isInt {
                    deviceElement.addChild(XMLElement(name: "id", stringValue: identifier.trimmingCharacters(in: CharacterSet.whitespaces)))
                } else {
                    deviceElement.addChild(XMLElement(name: "serial_number", stringValue: identifier.trimmingCharacters(in: CharacterSet.whitespaces)))
                }
                devicesElement.addChild(deviceElement)
            }
            root.addChild(isSmartElement)
            root.addChild(devicesElement)
            return xml.xmlData
        }

        if objectType == "users" {
            // Variables needed for the rest of the XML Generation
            let root = XMLElement(name: "user_group")
            let xml = XMLDocument(rootElement: root)
            let isSmartElement = XMLElement(name: "is_smart", stringValue: "false")
            var usersElement = XMLElement(name: "users")

            if appendReplaceRemove == "append" {
                usersElement = XMLElement(name: "user_additions")
            }
            if appendReplaceRemove == "replace" {
                usersElement = XMLElement(name: "users")
            }
            if appendReplaceRemove == "remove" {
                usersElement = XMLElement(name: "user_deletions")
            }

            // Loop
            for i in 0...(identifiers.count - 1){
                let userElement = XMLElement(name: "user")
                let identifier = identifiers[i]
                if identifier.isInt {
                    if xmlDefaults.value(forKey: "UserInts") != nil {
                        userElement.addChild(XMLElement(name: "username", stringValue: identifier.trimmingCharacters(in: CharacterSet.whitespaces)))
                    } else {
                        userElement.addChild(XMLElement(name: "id", stringValue: identifier.trimmingCharacters(in: CharacterSet.whitespaces)))
                    }
                } else {
                    userElement.addChild(XMLElement(name: "username", stringValue: identifier.trimmingCharacters(in: CharacterSet.whitespaces)))
                }
                usersElement.addChild(userElement)
            }
            root.addChild(isSmartElement)
            root.addChild(usersElement)
            return xml.xmlData
        }

        return Data("nil".utf8)
    }
    
    func populateElement(variableToCheck: String, elementName: String, elementToAdd: XMLElement, whereToAdd: XMLElement) {
        // Populate the element as needed
        var elementToAdd = XMLElement(name: elementName, stringValue: variableToCheck)
        
        if variableToCheck == removalValue {
            elementToAdd = XMLElement(name: elementName, stringValue: "")
            whereToAdd.addChild(elementToAdd)
        } else if variableToCheck != "" {
            whereToAdd.addChild(elementToAdd)
        }
        
    }


}
