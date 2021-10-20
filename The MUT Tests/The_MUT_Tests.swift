//
//  The_MUT_Tests.swift
//  The MUT Tests
//
//  Created by Michael Levenick on 6/16/19.
//  Copyright © 2019 Levenick Enterprises LLC. All rights reserved.
//

import XCTest
@testable import MUT



//*********************************************
//!BE AWARE!
//
//Many of the test cases in here are not actually testing for assertation.
//They are simply outputting an example of what the function should be returning.
//This is in large part because these functions are still changing constantly,
//and we just want to see what they are outputting without needing to fix
//the assertation on every change.
//
//Please manually review the output to ensure it is outputting properly,
//and do not assume a passed test means the function is working properly.
//*********************************************


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
    
    func testPostURL() {
        let baseURL = DataPrep.generateURL(baseURL: "https://test.jssmut.com", endpoint: "mobiledevicecommands", identifierType: "command", identifier: "device_name", jpapi: false, jpapiVersion: "")
        print(baseURL)
    }
    
    func testJpapiURL() {
        let baseURL = DataPrep.generateJpapiURL(baseURL: "https://test.jssmut.com", endpoint: "mobile-devices", endpointVersion: "v2", identifier: "1")
        print(baseURL)
    }
    
    func testJpapiURLNoIdentifier() {
        let baseURL = DataPrep.generateJpapiURL(baseURL: "https://test.jssmut.com", endpoint: "mobile-devices", endpointVersion: "v2", identifier: "")
        print(baseURL)
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

class staticGroupXMLTestsNonInt: XCTestCase {
    let xmlMan = xmlManager()
    
    func testComputerRemoval(){
        let myXML = xmlMan.staticGroup(appendReplaceRemove: "remove", objectType: "computers", identifiers: ["C11111","C22222","C33333"])
        print(String(decoding: myXML, as: UTF8.self))
    }
    
    func testComputerAdditions(){
        let myXML = xmlMan.staticGroup(appendReplaceRemove: "append", objectType: "computers", identifiers: ["C11111","C22222","C33333"])
        print(String(decoding: myXML, as: UTF8.self))
    }
    
    func testComputerReplace(){
        let myXML = xmlMan.staticGroup(appendReplaceRemove: "replace", objectType: "computers", identifiers: ["C11111","C22222","C33333"])
        print(String(decoding: myXML, as: UTF8.self))
    }
    
    func testMobileAdditions(){
        let myXML = xmlMan.staticGroup(appendReplaceRemove: "append", objectType: "mobiledevices", identifiers: ["C11111","C22222","C33333"])
        print(String(decoding: myXML, as: UTF8.self))
    }
    
    func testMobileRemoval(){
        let myXML = xmlMan.staticGroup(appendReplaceRemove: "remove", objectType: "mobiledevices", identifiers: ["C11111","C22222","C33333"])
        print(String(decoding: myXML, as: UTF8.self))
    }
    
    func testMobileReplace(){
        let myXML = xmlMan.staticGroup(appendReplaceRemove: "replace", objectType: "mobiledevices", identifiers: ["C11111","C22222","C33333"])
        print(String(decoding: myXML, as: UTF8.self))
    }
    
    func testUserAdditions(){
        let myXML = xmlMan.staticGroup(appendReplaceRemove: "append", objectType: "users", identifiers: ["C11111","C22222","C33333"])
        print(String(decoding: myXML, as: UTF8.self))
    }
    
    func testUserRemoval(){
        let myXML = xmlMan.staticGroup(appendReplaceRemove: "remove", objectType: "users", identifiers: ["C11111","C22222","C33333"])
        print(String(decoding: myXML, as: UTF8.self))
    }
    
    func testUserReplace(){
        let myXML = xmlMan.staticGroup(appendReplaceRemove: "replace", objectType: "users", identifiers: ["C11111","C22222","C33333"])
        print(String(decoding: myXML, as: UTF8.self))
    }
}

class staticGroupXMLTestsInt: XCTestCase {
    let xmlMan = xmlManager()
    
    func testComputerRemoval(){
        let myXML = xmlMan.staticGroup(appendReplaceRemove: "remove", objectType: "computers", identifiers: ["1","2","3"])
        print(String(decoding: myXML, as: UTF8.self))
    }
    
    func testComputerAdditions(){
        let myXML = xmlMan.staticGroup(appendReplaceRemove: "append", objectType: "computers", identifiers: ["1","2","3"])
        print(String(decoding: myXML, as: UTF8.self))
    }
    
    func testComputerReplace(){
        let myXML = xmlMan.staticGroup(appendReplaceRemove: "replace", objectType: "computers", identifiers: ["1","2","3"])
        print(String(decoding: myXML, as: UTF8.self))
    }
    
    func testMobileAdditions(){
        let myXML = xmlMan.staticGroup(appendReplaceRemove: "append", objectType: "mobiledevices", identifiers: ["1","2","3"])
        print(String(decoding: myXML, as: UTF8.self))
    }
    
    func testMobileRemoval(){
        let myXML = xmlMan.staticGroup(appendReplaceRemove: "remove", objectType: "mobiledevices", identifiers: ["1","2","3"])
        print(String(decoding: myXML, as: UTF8.self))
    }
    
    func testMobileReplace(){
        let myXML = xmlMan.staticGroup(appendReplaceRemove: "replace", objectType: "mobiledevices", identifiers: ["1","2","3"])
        print(String(decoding: myXML, as: UTF8.self))
    }
    
    func testUserAdditions(){
        let myXML = xmlMan.staticGroup(appendReplaceRemove: "append", objectType: "users", identifiers: ["1","2","3"])
        print(String(decoding: myXML, as: UTF8.self))
    }
    
    func testUserRemoval(){
        let myXML = xmlMan.staticGroup(appendReplaceRemove: "remove", objectType: "users", identifiers: ["1","2","3"])
        print(String(decoding: myXML, as: UTF8.self))
    }
    
    func testUserReplace(){
        let myXML = xmlMan.staticGroup(appendReplaceRemove: "replace", objectType: "users", identifiers: ["1","2","3"])
        print(String(decoding: myXML, as: UTF8.self))
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
        let userXML = xmlMan.userObject(username: "mike.levenick", full_name: "Mike Levenick", email_address: "mike.levenick@jssmut.com", phone_number: "715 955 4897", position: "Developer", ldap_server: "-1", ea_ids: ["1","2"], ea_values: ["Value1","Value2"], site_ident: "", managedAppleID: "mike.levenick@jssmut.com")
        let xmlString = String(decoding: userXML, as: UTF8.self)
        print(xmlString)
    }
    
    func testUserXML_Username() {
        let userXML = xmlMan.userObject(username: "VALUE", full_name: "", email_address: "", phone_number: "", position: "", ldap_server: "", ea_ids: [], ea_values: [], site_ident: "", managedAppleID: "mike.levenick@jssmut.com")
        let xmlString = String(decoding: userXML, as: UTF8.self)
        print(xmlString)
    }
    
    func testUserXML_FullName() {
        let userXML = xmlMan.userObject(username: "", full_name: "VALUE", email_address: "", phone_number: "", position: "", ldap_server: "", ea_ids: [], ea_values: [], site_ident: "", managedAppleID: "mike.levenick@jssmut.com")
        let xmlString = String(decoding: userXML, as: UTF8.self)
        print(xmlString)
    }
    
    func testUserXML_EmailAddress() {
        let userXML = xmlMan.userObject(username: "", full_name: "", email_address: "VALUE", phone_number: "", position: "", ldap_server: "", ea_ids: [], ea_values: [], site_ident: "", managedAppleID: "mike.levenick@jssmut.com")
        let xmlString = String(decoding: userXML, as: UTF8.self)
        print(xmlString)
    }
    
    func testUserXML_PhoneNumber() {
        let userXML = xmlMan.userObject(username: "", full_name: "", email_address: "", phone_number: "VALUE", position: "", ldap_server: "", ea_ids: [], ea_values: [], site_ident: "", managedAppleID: "mike.levenick@jssmut.com")
        let xmlString = String(decoding: userXML, as: UTF8.self)
        print(xmlString)
    }
    
    func testUserXML_Position() {
        let userXML = xmlMan.userObject(username: "", full_name: "", email_address: "", phone_number: "", position: "VALUE", ldap_server: "", ea_ids: [], ea_values: [], site_ident: "", managedAppleID: "mike.levenick@jssmut.com")
        let xmlString = String(decoding: userXML, as: UTF8.self)
        print(xmlString)
    }
    
    func testUserXML_LDAPServer() {
        let userXML = xmlMan.userObject(username: "", full_name: "", email_address: "", phone_number: "", position: "", ldap_server: "VALUE", ea_ids: [], ea_values: [], site_ident: "", managedAppleID: "mike.levenick@jssmut.com")
        let xmlString = String(decoding: userXML, as: UTF8.self)
        print(xmlString)
    }
    
    func testUserXML_EAs() {
        let userXML = xmlMan.userObject(username: "", full_name: "", email_address: "", phone_number: "", position: "", ldap_server: "", ea_ids: ["1","2"], ea_values: ["value1","value2"], site_ident: "", managedAppleID: "mike.levenick@jssmut.com")
        let xmlString = String(decoding: userXML, as: UTF8.self)
        print(xmlString)
    }
}
//
//class iOSXMLTests: XCTestCase {
//    let DataPrep = dataPreparation()
//    let xmlMan = xmlManager()
//
//    override func setUp() {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//        print("")
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        print("")
//    }
//
//    func testiOSXML_EAS() {
//        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: ["1","2"], ea_values: ["Value1","Value2"], site_ident: "")
//        let xmlString = String(decoding: iOSXML, as: UTF8.self)
//        print(xmlString)
//        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
//    }
//
//    func testiOSXML_Full() {
//        let iOSXML = xmlMan.iosObject(displayName: "Mikes Mini", assetTag: "JAMF1234", username: "mike.levenick", full_name: "Mike Levenick", email_address: "mike.levenick@jssmut.com", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: ["1","2"], ea_values: ["Value1","Value2"], site_ident: "")
//        let xmlString = String(decoding: iOSXML, as: UTF8.self)
//        print(xmlString)
//        //XCTAssertEqual(xmlString, "FIX ME")
//    }
//
//    func testiOSXML_DeviceName() {
//        let iOSXML = xmlMan.iosObject(displayName: "VALUE", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
//        let xmlString = String(decoding: iOSXML, as: UTF8.self)
//        print(xmlString)
//        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
//    }
//
//    func testiOSXML_AssetTag() {
//        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "VALUE", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
//        let xmlString = String(decoding: iOSXML, as: UTF8.self)
//        print(xmlString)
//        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
//    }
//
//    func testiOSXML_Username() {
//        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "VALUE", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
//        let xmlString = String(decoding: iOSXML, as: UTF8.self)
//        print(xmlString)
//        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
//    }
//
//    func testiOSXML_FullName() {
//        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "VALUE", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
//        let xmlString = String(decoding: iOSXML, as: UTF8.self)
//        print(xmlString)
//        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
//    }
//
//    func testiOSXML_EmailAddress() {
//        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "VALUE", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
//        let xmlString = String(decoding: iOSXML, as: UTF8.self)
//        print(xmlString)
//        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
//    }
//
//    func testiOSXML_PhoneNumber() {
//        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "VALUE", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
//        let xmlString = String(decoding: iOSXML, as: UTF8.self)
//        print(xmlString)
//        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
//    }
//
//    func testiOSXML_Position() {
//        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "VALUE", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
//        let xmlString = String(decoding: iOSXML, as: UTF8.self)
//        print(xmlString)
//        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
//    }
//
//    func testiOSXML_Department() {
//        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "VALUE", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
//        let xmlString = String(decoding: iOSXML, as: UTF8.self)
//        print(xmlString)
//        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
//    }
//
//    func testiOSXML_Building() {
//        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "VALUE", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
//        let xmlString = String(decoding: iOSXML, as: UTF8.self)
//        print(xmlString)
//        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
//    }
//
//    func testiOSXML_Room() {
//        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "VALUE", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
//        let xmlString = String(decoding: iOSXML, as: UTF8.self)
//        print(xmlString)
//        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
//    }
//
//    func testiOSXML_PONumber() {
//        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "VALUE", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
//        let xmlString = String(decoding: iOSXML, as: UTF8.self)
//        print(xmlString)
//        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
//    }
//
//    func testiOSXML_Vendor() {
//        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "VALUE", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
//        let xmlString = String(decoding: iOSXML, as: UTF8.self)
//        print(xmlString)
//        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
//    }
//
//    func testiOSXML_PODate() {
//        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "VALUE", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
//        let xmlString = String(decoding: iOSXML, as: UTF8.self)
//        print(xmlString)
//        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
//    }
//
//    func testiOSXML_WarrantyExpires() {
//        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "VALUE", leaseExpires: "", ea_ids: [], ea_values: [], site_ident: "")
//        let xmlString = String(decoding: iOSXML, as: UTF8.self)
//        print(xmlString)
//        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
//    }
//
//    func testiOSXML_LeaseExpires() {
//        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "VALUE", ea_ids: [], ea_values: [], site_ident: "")
//        let xmlString = String(decoding: iOSXML, as: UTF8.self)
//        print(xmlString)
//        //XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
//    }
//}

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
        let macOSXML = xmlMan.macosObject(displayName: "", assetTag: "", barcode1: "", barcode2: "", username: "", full_name: "", email_address: "", position: "", phone_number: "", department: "", building: "", room: "", poNumber: "", vendor: "", purchasePrice: "", poDate: "", warrantyExpires: "", isLeased: <#String#>, leaseExpires: "", appleCareID: "", site_ident: "", ea_ids: [], ea_values: [])
        let xmlString = String(decoding: macOSXML, as: UTF8.self)
        print(xmlString)
    }
}

class mobileDeviceJsonTests: XCTestCase {
    let dataPrep = dataPreparation()
    let apifunc = APIFunctions()
    let jsonMan = jsonManager()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        print("")
    }
    
    func testMobileDeviceUpdateJson() throws {
        // given
        let jsonEncoder = JSONEncoder()
        let userInputData: [String] = ["1", "Device Name", "TRUE"]
        let mobileDeviceUpdateData = MobileDeviceV2(name: "Device Name", enforceName: true)
        var expectedResultString = ""
        
        if let json = try? jsonEncoder.encode(mobileDeviceUpdateData) {
            expectedResultString = String(data: json, encoding: .utf8)!
        }
        
        // when
        let result = jsonMan.buildMobileDeviceUpdatesJson(data: userInputData)
        let resultString = String(data: result, encoding: .utf8)
        
        // then
        XCTAssertEqual(expectedResultString, resultString)
    }
}

class jamfProVersionTests: XCTestCase {
    let dataPrep = dataPreparation()
    let viewController = ViewController()
    let apifunc = APIFunctions()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        print("")
    }
    
    func testJamfProVersionCompareNotCompatible() {
        // given
        let jamfProVersion = "10.30.2"
        let compatibleVersion = "10.31"
        
        // when
        let result = viewController.isCompatibleJamfProVersion(compatibleVersion: compatibleVersion, currentVersion: jamfProVersion)
        
        // then
        XCTAssertFalse(result)
    }
    
    func testJamfProVersionCompareCompatible() {
        // given
        let jamfProVersion = "10.30.2"
        let compatibleVersion = "10.30.0"
        
        // when
        let result = viewController.isCompatibleJamfProVersion(compatibleVersion: compatibleVersion, currentVersion: jamfProVersion)
        
        // then
        XCTAssertTrue(result)
    }
}
