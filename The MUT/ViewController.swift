//
//  ViewController.swift
//  The MUT
//
//  Created by Michael Levenick on 10/17/16.
//  Copyright © 2016 Levenick Enterprises LLC. All rights reserved.
//

import Cocoa



class ViewController: NSViewController, DataSentURL {
    var globalServerURL: String!
    
    // Takes place right after view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = NSSize(width: 600, height: 400)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    // Declare outlets for debug labels
    @IBOutlet weak var lblTest: NSTextField!
    @IBOutlet weak var lblTest2: NSTextField!
    @IBOutlet weak var lblTest3: NSTextField!
    
    // Declare outlets for Buttons
    @IBOutlet weak var btnServer: NSButton!
    
    
    func userDidEnterURL(serverURL: String) {
        lblTest.stringValue = serverURL
        globalServerURL = serverURL
        btnServer.image = NSImage(named: "NSStatusAvailable")
        btnServer.isEnabled = false
    }
    
    // Function for segue variable passing
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueServer" {
            let ServerView: ServerView = segue.destinationController as! ServerView
            ServerView.delegateURL = self
        }
        
        //if segue.identifier == "mySegue2" {
        //    let SendingVC2: SendingVC2 = segue.destinationController as! SendingVC2
        //    SendingVC2.delegateURL = self
        //}
        
    }
    
    @IBAction func printInfo(_ sender: AnyObject) {
        print(globalServerURL)
    }
    

}
