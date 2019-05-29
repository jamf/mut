//
//  loginWindow.swift
//  The MUT
//
//  Created by Michael Levenick on 5/28/19.
//  Copyright © 2019 Levenick Enterprises LLC. All rights reserved.
//

import Cocoa
import Foundation

// Delegate required to send data forward to the main view controller
protocol DataSentDelegate {
    func userDidAuthenticate(base64Credentials: String, url: String)
}

class loginWindow: NSViewController, URLSessionDelegate {

    let loginDefaults = UserDefaults.standard
    var delegateAuth: DataSentDelegate? = nil


    @IBOutlet weak var txtURLOutlet: NSTextField!
    @IBOutlet weak var txtUserOutlet: NSTextField!
    @IBOutlet weak var txtPassOutlet: NSSecureTextField!
    @IBOutlet weak var spinProgress: NSProgressIndicator!
    @IBOutlet weak var btnSubmitOutlet: NSButton!
    @IBOutlet weak var chkRememberMe: NSButton!
    @IBOutlet weak var chkBypass: NSButton!

    var doNotRun: Bool!
    var serverURL: String!
    var base64Credentials: String!
    var token: String!
    var verified = false

    let punctuation = CharacterSet(charactersIn: ".:/")

    let APIFunc = API()

    override func viewDidLoad() {
        super.viewDidLoad()


        // Restore the Username to text box if we have a default stored
        if loginDefaults.value(forKey: "UserName") != nil {
            txtUserOutlet.stringValue = loginDefaults.value(forKey: "UserName") as! String
        }

        // Restore Prem URL to text box if we have a default stored
        if loginDefaults.value(forKey: "InstanceURL") != nil {
            txtURLOutlet.stringValue = loginDefaults.value(forKey: "InstanceURL") as! String
        }

        if ( loginDefaults.value(forKey: "InstanceURL") != nil || loginDefaults.value(forKey: "InstanceURL") != nil ) && loginDefaults.value(forKey: "UserName") != nil {
            if self.txtPassOutlet.acceptsFirstResponder == true {
                self.txtPassOutlet.becomeFirstResponder()
            }
        }

        if loginDefaults.value(forKey: "Remember") != nil {
            if loginDefaults.bool(forKey: "Remember") {
                chkRememberMe.state = convertToNSControlStateValue(1)
            } else {
                chkRememberMe.state = convertToNSControlStateValue(0)
            }
        } else {
            // Just in case you ever want to do something for no default stored
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        preferredContentSize = NSSize(width: 450, height: 600)
        // If we have a URL and a User stored focus the password field
        if loginDefaults.value(forKey: "InstanceURL") != nil  && loginDefaults.value(forKey: "UserName") != nil {
            self.txtPassOutlet.becomeFirstResponder()
        }
    }

    @IBAction func btnSubmit(_ sender: Any) {
        doNotRun = false

        // Clean up whitespace at the beginning and end of the fields, in case of faulty copy/paste
        txtURLOutlet.stringValue = txtURLOutlet.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)
        txtUserOutlet.stringValue = txtUserOutlet.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)
        txtPassOutlet.stringValue = txtPassOutlet.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)

        // Warn the user if they have failed to enter an instancename AND prem URL
        if txtURLOutlet.stringValue == "" {
            _ = popPrompt().generalWarning(question: "No Server Info", text: "It appears that you have not entered any information for your Jamf Pro URL. Please enter either a Jamf Cloud instance name, or your full URL if you host your own server.")
            doNotRun = true // Set Do Not Run flag
        }

        // Warn the user if they have failed to enter a username
        if txtUserOutlet.stringValue == "" {
            _ = popPrompt().generalWarning(question: "No Username Found", text: "It appears that you have not entered a username for MUT to use while accessing Jamf Pro. Please enter your username and password, and try again.")
            doNotRun = true // Set Do Not Run flag
        }

        // Warn the user if they have failed to enter a password
        if txtPassOutlet.stringValue == "" {
            _ = popPrompt().generalWarning(question: "No Password Found", text: "It appears that you have not entered a password for MUT to use while accessing Jamf Pro. Please enter your username and password, and try again.")
            doNotRun = true // Set Do Not Run flag
        }

        // Move forward with verification if we have not flagged the doNotRun flag
        if !doNotRun {

            let tokenData = APIFunc.verifyCredentials(url: txtURLOutlet.stringValue, user: txtUserOutlet.stringValue, password: txtPassOutlet.stringValue)
            print(String(decoding: tokenData, as: UTF8.self))


            //btnSubmitOutlet.isHidden = true
            //spinProgress.startAnimation(self)

            // Concatenate the credentials and base64 encode the resulting string
            //let concatCredentials = "\(txtUserOutlet.stringValue):\(txtPassOutlet.stringValue)"
            //let utf8Credentials = concatCredentials.data(using: String.Encoding.utf8)
            //base64Credentials = utf8Credentials?.base64EncodedString()

            // MARK - Credential Verification API Call


            // Commenting out the old API call, as this is the primary thing to clean up.
            // Use the new API class, and build the function there.
            /*DispatchQueue.main.async {
                let myURL = xmlBuilder().createGETURL(url: self.serverURL!)
                let request = NSMutableURLRequest(url: myURL)
                request.httpMethod = "GET"
                let configuration = URLSessionConfiguration.default
                configuration.httpAdditionalHeaders = ["Authorization" : "Basic \(self.base64Credentials!)", "Content-Type" : "text/xml", "Accept" : "text/xml"]
                let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
                let task = session.dataTask(with: request as URLRequest, completionHandler: {
                    (data, response, error) -> Void in
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode >= 199 && httpResponse.statusCode <= 299 {
                            self.verified = true

                            // Store username if button pressed
                            if self.chkRememberMe.state.rawValue == 1 {
                                self.loginDefaults.set(self.txtUserOutlet.stringValue, forKey: "UserName")
                                self.loginDefaults.set(self.txtURLOutlet.stringValue, forKey: "InstanceURL")
                                self.loginDefaults.set(true, forKey: "Remember")
                                self.loginDefaults.synchronize()

                            } else {
                                self.loginDefaults.removeObject(forKey: "UserName")
                                self.loginDefaults.removeObject(forKey: "InstanceURL")
                                self.loginDefaults.set(false, forKey: "Remember")
                                self.loginDefaults.synchronize()
                            }
                            self.spinProgress.stopAnimation(self)
                            self.btnSubmitOutlet.isHidden = false

                            if self.delegateAuth != nil {
                                self.delegateAuth?.userDidAuthenticate(base64Credentials: self.base64Credentials!, url: self.serverURL!)
                                self.dismiss(self)
                            }

                        } else {
                            DispatchQueue.main.async {
                                self.spinProgress.stopAnimation(self)
                                self.btnSubmitOutlet.isHidden = false
                                _ = popPrompt().generalWarning(question: "Invalid Credentials", text: "The credentials you entered do not seem to have sufficient permissions. This could be due to an incorrect user/password, or possibly from insufficient permissions. MUT tests this against the user's ability to view the Activation Code via the API.")
                                if self.chkBypass.state.rawValue == 1 {
                                    if self.delegateAuth != nil {
                                        self.delegateAuth?.userDidAuthenticate(base64Credentials: self.base64Credentials!, url: self.serverURL!)
                                        self.dismiss(self)
                                    }
                                    self.verified = true
                                }
                            }
                        }
                    }
                    if error != nil {
                        _ = popPrompt().generalWarning(question: "Fatal Error", text: "The MUT received a fatal error at authentication. The most common cause of this is an incorrect server URL. The full error output is below. \n\n \(error!.localizedDescription)")
                        self.spinProgress.stopAnimation(self)
                        self.btnSubmitOutlet.isHidden = false
                    }
                })
                task.resume()
            }
            */


        } else {
            // Reset the Do Not Run flag so that on subsequent runs we try the checks again.
            doNotRun = false
        }
    }

    // This is required to allow un-trusted SSL certificates. Leave it alone.
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    @IBAction func btnQuit(_ sender: Any) {
        self.dismiss(self)
        NSApplication.shared.terminate(self)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSControlStateValue(_ input: Int) -> NSControl.StateValue {
    return NSControl.StateValue(rawValue: input)
}
