//
//  ViewController.swift
//  The MUT
//
//  Created by Michael Levenick on 10/17/16.
//  Copyright © 2016 Levenick Enterprises LLC. All rights reserved.
//


import Cocoa
import Foundation

class loginWindow: NSViewController, URLSessionDelegate {

    @IBOutlet weak var txtCloudOutlet: NSTextField!
    @IBOutlet weak var txtPremOutlet: NSTextField!
    
    @IBAction func txtPrem(_ sender: Any) {

    }
    @IBAction func txtCloud(_ sender: Any) {

    }
    
    @IBAction func btnSubmit(_ sender: Any) {
        self.dismiss(self)
    }
}

