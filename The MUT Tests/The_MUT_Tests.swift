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
    let DataMan = dataManipulation()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let base64Creds = DataMan.base64Credentials(user: "ladmin", password: "jamf1234")
        XCTAssertEqual(base64Creds, "bGFkbWluOmphbWYxMjM0")
    }
    
    func testURLEncoding() {
        let encodedURL = DataMan.generateURL(baseURL: "mlevenick", endpoint: "computers", identifierType: "id", identifier: "1", jpapi: false, jpapiVersion: "")
        XCTAssertEqual(encodedURL.absoluteString, "https://mlevenick.jamfcloud.com/JSSResource/computers/id/1")
    }
    
    func testURLSpaces() {
        let encodedURL = DataMan.generateURL(baseURL: "mlevenick", endpoint: "users", identifierType: "name", identifier: "mike levenick", jpapi: false, jpapiVersion: "")
        XCTAssertEqual(encodedURL.absoluteString, "https://mlevenick.jamfcloud.com/JSSResource/users/name/mike%20levenick")
    }
    
    func testIsInt() {
        let notInt = "A"
        let yesInt = "1"
        XCTAssertTrue(yesInt.isInt)
        XCTAssertFalse(notInt.isInt)
    }
    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            let DataMan = dataManipulation()
            _ = DataMan.base64Credentials(user: "ladmin", password: "jamf1234")
        }
    }

}
