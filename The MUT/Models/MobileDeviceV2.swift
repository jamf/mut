//
//  MobileDevice.swift
//  MUT
//
//  Created by Nate Anderson on 8/31/21.
//  Copyright © 2021 Levenick Enterprises LLC. All rights reserved.
//

import Foundation

// Respresents a Mobile Device object in JPAPI. Version (i.e. V2) of the object
// matches the version of the endpoint, as the object may change with an API
// version change. All fields included here so that they may be utilized in a
// future version of MUT where the JPAPI is fully integrated.
struct MobileDeviceV2: Codable {
    var name: String?
    var enforceName: Bool?
    var assetTag: String?
    var siteId: String?
    var timeZone: String?
    var location: Location?
    var updatedExtensionAttributes: [UpdatedExtensionAttributes]?
    var ios: Ios?
    var tvos: Tvos?
}

struct Location: Codable, Equatable {
    var username: String?
    var realName: String?
    var emailAddress: String?
    var position: String?
    var phoneNumber: String?
    var departmentId: String?
    var buildingId: String?
    var room: String?
}

struct UpdatedExtensionAttributes: Codable {
    var id: String?
    var name: String?
    var type: String?
    var value: [String]
    var extensionAttributeCollectionAllowed: Bool?
}

struct Ios: Codable, Equatable {
    var purchasing: Purchasing?
}

struct Tvos: Codable, Equatable {
    var airplayPassword: String?
    var purchasing: Purchasing?
}

struct Purchasing: Codable, Equatable {
    var purchased: Bool?
    var leased: Bool?
    var poNumber: String?
    var vendor: String?
    var appleCareId: String?
    var purchasePrice: String?
    var purchasingAccount: String?
    var poDate: String?
    var warrantyExpiresDate: String?
    var leaseExpiresDate: String?
    var lifeExpectancy: Int?
    var purchasingContact: String?
}
