//
//  xmlBuilder.swift
//  The MUT v5
//
//  Created by Michael Levenick on 5/24/19.
//  Copyright © 2019 Michael Levenick. All rights reserved.
//

import Cocoa
import Foundation

public class xmlManager {
    // Globally declaring the xml variable to allow the various functions to populate it
    var xml: XMLDocument?
    
    // User Object update XML Creation:
    
    /*
     <user>
         <name>Abigail Anderson</name> // This is actually username
         <full_name/> // Full name (obv)
         <email/> // Email
         <email_address/> // Also email
         <phone_number/>
         <position/>
         <ldap_server>
             <id>-1</id>
         </ldap_server>
         <extension_attributes>
             <extension_attribute>
                 <id>1</id>
                 <value>Something</value>
             </extension_attribute>
         </extension_attributes>
         <sites/>
     </user>
     */
    
    public func userObject(username: String, full_name: String, email_address: String, phone_number: String, position: String, ldap_server: String) -> Data {
        // BUILD XML FOR LDAP SERVER USER UPDATES
        
        // Variables needed to dynamically build the EA portion of the XML
        var eaIDs = [XMLElement]()
        eaIDs = [XMLElement(name: "id", stringValue: "1"), XMLElement(name: "id", stringValue: "2")]
        var eaValues = [XMLElement]()
        eaValues = [XMLElement(name: "value", stringValue: "Monkey"), XMLElement(name: "value", stringValue: "Banana")]
        
        // Variables needed for the rest of the XML Generation
        let root = XMLElement(name: "user")
        let xml = XMLDocument(rootElement: root)
        let username = XMLElement(name: "name", stringValue: username)
        let fullName = XMLElement(name: "full_name", stringValue: full_name)
        let email = XMLElement(name: "email", stringValue: email_address)
        let emailAddress = XMLElement(name: "email_address", stringValue: email_address)
        let phoneNumber = XMLElement(name: "phone_number", stringValue: phone_number)
        let position = XMLElement(name: "position", stringValue: position)
        let ldapServer = XMLElement(name: "ldap_server")
        let ldapServerID = XMLElement(name: "id", stringValue: ldap_server) // Set LDAP Server ID to -1 to unassign from all.
        let extensionAttributes = XMLElement(name: "extension_attributes")
        
        // Add all the XML Nodes to the root element
        //root.addChild(username)
        root.addChild(fullName)
        root.addChild(email)
        root.addChild(emailAddress)
        root.addChild(phoneNumber)
        root.addChild(position)
//        ldapServer.addChild(ldapServerID)
        //root.addChild(ldapServer)
        
        // Loop through the EA values, adding them to the EA node
        for i in 1...2 {
            let currentEAID = eaIDs[i-1]
            let currentEAValue = eaValues[i-1]
            let currentExtensionAttributes = XMLElement(name: "extension_attribute")
            currentExtensionAttributes.addChild(currentEAID)
            currentExtensionAttributes.addChild(currentEAValue)
            extensionAttributes.addChild(currentExtensionAttributes)
        }
        
        // Add the EA subset to the root element
        //root.addChild(extensionAttributes)
        
        // Print the XML
        print(xml.debugDescription) // Uncomment for debugging
        
        return xml.xmlData
    }
    
}
