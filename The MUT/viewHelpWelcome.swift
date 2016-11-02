//
//  viewHelpWelcome.swift
//  The MUT
//
//  Created by Michael Levenick on 11/2/16.
//  Copyright © 2016 Levenick Enterprises LLC. All rights reserved.
//

import Foundation
import Cocoa

class viewHelpWelcome: NSViewController {
    
    var disappeared: String!
    
    override func viewDidAppear() {
        let mainQueue = DispatchQueue.main
        let deadline = DispatchTime.now() + .seconds(5)
        mainQueue.asyncAfter(deadline: deadline) {
            if self.disappeared == nil {
                self.dismissViewController(self)
            }
        }
    }
    override func viewWillDisappear() {
        self.disappeared = "true"
    }

}
