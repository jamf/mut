//
//  The_MUT_Tests.swift
//  The MUT Tests
//
//  Created by Michael Levenick on 6/16/19.
//  Copyright © 2019 Levenick Enterprises LLC. All rights reserved.
//

import XCTest
@testable import MUT



class genericDataValidation: XCTestCase {
    let DataPrep = dataPreparation()
    let xmlMan = xmlManager()
    let apifunc = APIFunctions()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        print("")
    }

    func testExample() {
        let base64Creds = DataPrep.base64Credentials(user: "ladmin", password: "jamf1234")
        XCTAssertEqual(base64Creds, "bGFkbWluOmphbWYxMjM0")
    }
    
    func testURLEncoding() {
        let encodedURL = DataPrep.generateURL(baseURL: "mlevenick", endpoint: "computers", identifierType: "id", identifier: "1", jpapi: false, jpapiVersion: "")
        XCTAssertEqual(encodedURL.absoluteString, "https://mlevenick.jamfcloud.com/JSSResource/computers/id/1")
    }
    
    func testURLSpaces() {
        let encodedURL = DataPrep.generateURL(baseURL: "mlevenick", endpoint: "users", identifierType: "name", identifier: "mike levenick", jpapi: false, jpapiVersion: "")
        XCTAssertEqual(encodedURL.absoluteString, "https://mlevenick.jamfcloud.com/JSSResource/users/name/mike%20levenick")
    }
    
    func testIsInt() {
        let notInt = "A"
        let yesInt = "1"
        XCTAssertTrue(yesInt.isInt)
        XCTAssertFalse(notInt.isInt)
    }

    func testDataGet() {
        print("")
        print("beginning testDataGet...")
        print("")
        let myURL = DataPrep.generateGetURL(baseURL: "https://test.jssmut.com", endpoint: "computer-prestages", prestageID: "1", jpapiVersion: "v1")
        print(myURL)

        let response = apifunc.getPrestageScope(passedUrl: myURL, token: "eyJhbGciOiJIUzI1NiJ9.eyJhdXRoZW50aWNhdGVkLWFwcCI6IkdFTkVSSUMiLCJhdXRoZW50aWNhdGlvbi10eXBlIjoiSlNTIiwiZ3JvdXBzIjpbXSwic3ViamVjdC10eXBlIjoiSlNTX1VTRVJfSUQiLCJ0b2tlbi11dWlkIjoiMWJkZTY3NzQtMjIxNy00N2NlLThjZjItOTE0YjQ4OTk1NGFhIiwibGRhcC1zZXJ2ZXItaWQiOi0xLCJzdWIiOiIyIiwiZXhwIjoxNTYxOTUwNjU0fQ.KekIFdTUtQGU-dt4OuLFMcQ1KZWmWJNSuGT5Zv359WU", endpoint: "computer-prestages", allowUntrusted: true)
        let myDataString = String(decoding: response, as: UTF8.self)
        
        print("")
        print("printing myDataString...")
        print("")
        print(myDataString)
    }
    
    
    func parseJSONString() {
        let dataString = """
        {
            "prestageId" : 1,
            "assignments" : [ {
            "serialNumber" : "C02VX0UDHV2R",
            "assignmentEpoch" : 1561829858206,
            "userAssigned" : "mike"
            } ],
            "versionLock" : 3
        }
        """
        
        let splitString = dataString.components(separatedBy: ",")
        print("splitString first value is: \(splitString[0])")
        
    }
    
}

class userXMLTests: XCTestCase {
    let DataPrep = dataPreparation()
    let xmlMan = xmlManager()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        print("")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        print("")
    }
    
    func testUserXML_Full() {
        let userXML = xmlMan.userObject(username: "mike.levenick", full_name: "Mike Levenick", email_address: "mike.levenick@jssmut.com", phone_number: "715 955 4897", position: "Developer", ldap_server: "-1", ea_ids: ["1","2"], ea_values: ["Value1","Value2"], site_ident: "")
        let xmlString = String(decoding: userXML, as: UTF8.self)
        print(xmlString)
    }
    
    func testUserXML_Username() {
        let userXML = xmlMan.userObject(username: "VALUE", full_name: "", email_address: "", phone_number: "", position: "", ldap_server: "", ea_ids: [], ea_values: [], site_ident: "")
        let xmlString = String(decoding: userXML, as: UTF8.self)
        print(xmlString)
    }
    
    func testUserXML_FullName() {
        let userXML = xmlMan.userObject(username: "", full_name: "VALUE", email_address: "", phone_number: "", position: "", ldap_server: "", ea_ids: [], ea_values: [], site_ident: "")
        let xmlString = String(decoding: userXML, as: UTF8.self)
        print(xmlString)
    }
    
    func testUserXML_EmailAddress() {
        let userXML = xmlMan.userObject(username: "", full_name: "", email_address: "VALUE", phone_number: "", position: "", ldap_server: "", ea_ids: [], ea_values: [], site_ident: "")
        let xmlString = String(decoding: userXML, as: UTF8.self)
        print(xmlString)
    }
    
    func testUserXML_PhoneNumber() {
        let userXML = xmlMan.userObject(username: "", full_name: "", email_address: "", phone_number: "VALUE", position: "", ldap_server: "", ea_ids: [], ea_values: [], site_ident: "")
        let xmlString = String(decoding: userXML, as: UTF8.self)
        print(xmlString)
    }
    
    func testUserXML_Position() {
        let userXML = xmlMan.userObject(username: "", full_name: "", email_address: "", phone_number: "", position: "VALUE", ldap_server: "", ea_ids: [], ea_values: [], site_ident: "")
        let xmlString = String(decoding: userXML, as: UTF8.self)
        print(xmlString)
    }
    
    func testUserXML_LDAPServer() {
        let userXML = xmlMan.userObject(username: "", full_name: "", email_address: "", phone_number: "", position: "", ldap_server: "VALUE", ea_ids: [], ea_values: [], site_ident: "")
        let xmlString = String(decoding: userXML, as: UTF8.self)
        print(xmlString)
    }
    
    func testUserXML_EAs() {
        let userXML = xmlMan.userObject(username: "", full_name: "", email_address: "", phone_number: "", position: "", ldap_server: "", ea_ids: ["1","2"], ea_values: ["value1","value2"], site_ident: "")
        let xmlString = String(decoding: userXML, as: UTF8.self)
        print(xmlString)
    }
}

class iOSXMLTests: XCTestCase {
    let DataPrep = dataPreparation()
    let xmlMan = xmlManager()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        print("")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        print("")
    }
    
    func testiOSXML_EAS() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: ["1","2"], ea_values: ["Value1","Value2"], site_ident: "")
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        print(xmlString)
        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }
    
    func testiOSXML_Full() {
        let iOSXML = xmlMan.iosObject(displayName: "Mikes Mini", assetTag: "JAMF1234", username: "mike.levenick", full_name: "Mike Levenick", email_address: "mike.levenick@jssmut.com", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: ["1","2"], ea_values: ["Value1","Value2"], site_ident: "")
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        print(xmlString)
        //XCTAssertEqual(xmlString, "FIX ME")
    }
    
    func testiOSXML_DeviceName() {
        let iOSXML = xmlMan.iosObject(displayName: "VALUE", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        print(xmlString)
        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }
    
    func testiOSXML_AssetTag() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "VALUE", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        print(xmlString)
        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }
    
    func testiOSXML_Username() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "VALUE", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        print(xmlString)
        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }
    
    func testiOSXML_FullName() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "VALUE", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        print(xmlString)
        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }
    
    func testiOSXML_EmailAddress() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "VALUE", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        print(xmlString)
        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }
    
    func testiOSXML_PhoneNumber() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "VALUE", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        print(xmlString)
        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }
    
    func testiOSXML_Position() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "VALUE", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        print(xmlString)
        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }
    
    func testiOSXML_Department() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "VALUE", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        print(xmlString)
        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }
    
    func testiOSXML_Building() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "VALUE", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        print(xmlString)
        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }
    
    func testiOSXML_Room() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "VALUE", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        print(xmlString)
        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }
    
    func testiOSXML_PONumber() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "VALUE", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        print(xmlString)
        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }
    
    func testiOSXML_Vendor() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "VALUE", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        print(xmlString)
        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }
    
    func testiOSXML_PODate() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "VALUE", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        print(xmlString)
        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }
    
    func testiOSXML_WarrantyExpires() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "VALUE", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        print(xmlString)
        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }
    
    func testiOSXML_LeaseExpires() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "VALUE", ea_ids: [], ea_values: [], site_ident: "")
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        print(xmlString)
        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }
}

class macOSXMLTests: XCTestCase {
    let DataPrep = dataPreparation()
    let xmlMan = xmlManager()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        print("")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        print("")
    }
    
    func testmacOSXML_LDAP() {
        let macOSXML = xmlMan.macosObject(displayName: "", assetTag: "", barcode1: "", barcode2: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "1")
        let xmlString = String(decoding: macOSXML, as: UTF8.self)
        print(xmlString)
        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }
    
    
}
