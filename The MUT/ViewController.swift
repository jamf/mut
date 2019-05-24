//
//  ViewController.swift
//  The MUT v5
//
//  Created by Michael Levenick on 5/24/19.
//  Copyright © 2019 Michael Levenick. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    let APIFunc = API()
    let dataMan = dataManipulation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let token = APIFunc.generateToken(url: "https://mlevenick.jamfcloud.com/", user: "apiadmin", password: "jamf1234")
        let myvar = dataMan.generateURL(baseURL: "string", endpoint: "endpoint", jpapi: false, jpapiVersion: "v1")
        print(myvar)
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
}

