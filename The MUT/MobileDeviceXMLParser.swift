//
//  MobileDeviceXMLParser.swift
//  MUT
//
//  Created by Nate Anderson on 8/31/21.
//  Copyright © 2021 Levenick Enterprises LLC. All rights reserved.
//

import Foundation

class MobileDeviceXMLParser: NSObject, XMLParserDelegate {
    
    private var currentElement = ""
    private var currentElementValue = ""
    private var id = ""
    
    public func getMobileDeviceIdFromResponse(data: Data) -> String {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return id
    }
    
    // starting tag of element
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
    }
    
    // value of element
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement == "id" {
            id = string
        }
    }
}
