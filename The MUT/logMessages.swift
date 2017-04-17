//
//  logMessages.swift
//  The MUT
//
//  Created by Michael Levenick on 4/17/17.
//  Copyright © 2017 Levenick Enterprises LLC. All rights reserved.
//

import Cocoa
import Foundation

public class logMessages {
    let myFontAttribute = [ NSFontAttributeName: NSFont(name: "Courier", size: 12.0)! ]

    public func appendRed(stringToAppend: String){
        ViewController().lblCurrent.stringValue = "Test"
        //ViewController().txtMain.textStorage?.append(NSAttributedString(string: "This is a test\n", attributes: self.myFontAttribute))
        //ViewController().txtMain.scrollToEndOfDocument(self)
    }
    
    public func appendLogString(stringToAppend: String) {
        
    }
    


}
