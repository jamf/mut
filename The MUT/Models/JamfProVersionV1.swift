//
//  JamfProVersion.swift
//  MUT
//
//  Created by Nate Anderson on 9/1/21.
//  Copyright © 2021 Levenick Enterprises LLC. All rights reserved.
//

import Foundation

// Respresents a Jamf Pro Version object in JPAPI.

struct JamfProVersionV1: Codable {
    var version: String?
}
