//
//  ViewController.swift
//  The MUT v5
//
//  Created by Michael Levenick on 5/24/19.
//  Copyright © 2019 Michael Levenick. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, URLSessionDelegate, DataSentDelegate {

    func userDidAuthenticate(base64Credentials: String, url: String) {
        // code
    }

    
    let APIFunc = API()
    let dataMan = dataManipulation()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //let token = APIFunc.generateToken(url: "https://mlevenick.jamfcloud.com/", user: "apiadmin", password: "jamf1234")
        //print(String(decoding: token, as: UTF8.self))
        
        //let extendedToken = APIFunc.extendToken(url: "https://mlevenick.jamfcloud.com/", user: "apiadmin", password: "jamf1234")
        //print(String(decoding: extendedToken, as: UTF8.self))
        // Do any additional setup after loading the view.
        //performSegue(withIdentifier: "segueLogin", sender: self)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueLogin" {
            let loginWindow: loginWindow = segue.destinationController as! loginWindow
            loginWindow.delegateAuth = self as! DataSentDelegate
        }
    }

    override func viewWillAppear() {
        //resize the view
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 450, height: 600)
        performSegue(withIdentifier: "segueLogin", sender: self)
    }
}

