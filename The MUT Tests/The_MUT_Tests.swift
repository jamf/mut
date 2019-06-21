//
//  The_MUT_Tests.swift
//  The MUT Tests
//
//  Created by Michael Levenick on 6/16/19.
//  Copyright © 2019 Levenick Enterprises LLC. All rights reserved.
//

import XCTest
@testable import MUT

class The_MUT_Tests: XCTestCase {
    let DataPrep = dataPreparation()
    let xmlMan = xmlManager()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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

    func testiOSXML_Full() {
        let iOSXML = xmlMan.iosObject(displayName: "Mikes Mini", assetTag: "JAMF1234", username: "mike.levenick", full_name: "Mike Levenick", email_address: "mike.levenick@jssmut.com", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: ["1","2"], ea_values: ["Value1","Value2"])
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        XCTAssertEqual(xmlString, "FIX ME")
    }

    func testiOSXML_DeviceName() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [])
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }

    func testiOSXML_AssetTag() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [])
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }

    func testiOSXML_Username() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [])
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }

    func testiOSXML_FullName() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [])
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }

    func testiOSXML_EmailAddress() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [])
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }

    func testiOSXML_PhoneNumber() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [])
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }

    func testiOSXML_Position() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [])
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }

    func testiOSXML_Department() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [])
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }

    func testiOSXML_Building() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [])
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }

    func testiOSXML_Room() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [])
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }

    func testiOSXML_PONumber() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [])
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }

    func testiOSXML_Vendor() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [])
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }

    func testiOSXML_PODate() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [])
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }

    func testiOSXML_WarrantyExpires() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [])
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }

    func testiOSXML_LeaseExpires() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [])
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }

    func testiOSXML_EAS() {
        let iOSXML = xmlMan.iosObject(displayName: "", assetTag: "", username: "", full_name: "", email_address: "", phone_number: "", position: "", department: "", building: "", room: "", poNumber: "", vendor: "", poDate: "", warrantyExpires: "", leaseExpires: "", ea_ids: [], ea_values: [])
        let xmlString = String(decoding: iOSXML, as: UTF8.self)
        XCTAssertEqual(xmlString, "<mobile_device><general></general><location></location><purchasing></purchasing><extension_attributes></extension_attributes></mobile_device>")
    }

}
