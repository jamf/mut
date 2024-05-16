//
//  API.swift
//  The MUT v5
//
//  Created by Michael Levenick on 5/24/19.
//  Copyright © 2019 Levenick Enterprises, LLC. All rights reserved.
//

import Foundation
import SwiftyJSON

public class tokenManagement: NSObject {
    
    let logMan = logManager()
    let sessionHandler = SessionHandler.SharedSessionHandler
    let tokenDefaults = UserDefaults.standard

    
    // This function can be used to generate a token. Pass in a URL and base64 encoded credentials.
    // The credentials are inserted into the header.
    public func getToken(allowUntrusted: Bool){
        let dataPrep = dataPreparation()

        // Percent encode special characters that are not allowed in URLs, such as spaces
        let encodedURL = "\(Credentials.server!)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "https://null"

        // Create a URL for getting a token.
        let tokenURL = dataPrep.generateJpapiURL(endpoint: "auth/token", endpointVersion: "v1", identifier: "")
        
        // The semaphore is what allows us to force the code to wait for this request to complete
        // Without the semaphore, MUT will queue up a request for every single line of the CSV simultaneously
        let semaphore = DispatchSemaphore(value: 0)
        let request = NSMutableURLRequest(url: tokenURL)

        // Determine the request type. If we pass this in with a variable, we could use this function for PUT as well.
        request.httpMethod = "POST"
        
        request.addValue("Basic \(Credentials.base64Encoded!)", forHTTPHeaderField: "Authorization" )
        request.addValue("text/xml", forHTTPHeaderField: "Content-Type")
        // set session to use
        let session = sessionHandler.mySession
        sessionHandler.setAllowUntrusted(allowUntrusted: allowUntrusted)
        
        // Completion handler. This is what ensures that the response is good/bad
        // and also what handles the semaphore
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode >= 199 && httpResponse.statusCode <= 299 {
                    // Good response from API
                    Token.data = data!
                    //NSLog("[INFO  ]: Successful GET completed by The MUT.app")
                    self.logMan.writeLog(level: .info, logString: "A new token was successfully generated by MUT.  \(httpResponse.statusCode).")
                    //self.logMan.writeLog(level: .info, logString: String(decoding: token, as: UTF8.self))
                } else {
                    // Bad Response from API
                    Token.data = data!
                    self.logMan.writeLog(level: .error, logString: "MUT Failed to generate a token.  \(httpResponse.statusCode).")
                    self.logMan.writeLog(level: .error, logString: String(decoding: Token.data!, as: UTF8.self))
                }
                semaphore.signal() // Signal completion to the semaphore
            }
            
            if error != nil {
                let errorString = "[FATAL ]: " + error!.localizedDescription
                Token.data = errorString.data(using: .utf8)!
                //NSLog("[FATAL ]: " + error!.localizedDescription)
                self.logMan.writeLog(level: .fatal, logString: error!.localizedDescription)
                semaphore.signal() // Signal completion to the semaphore
            }
        })
        task.resume() // Kick off the actual GET here
        semaphore.wait() // Wait for the semaphore before moving on to the return value
        
        if String(decoding: Token.data!, as: UTF8.self).contains("FATAL") {
            _ = popPrompt().fatalWarning(error: String(decoding: Token.data!, as: UTF8.self))
        } else {
            // No error found leads you here:
            if String(decoding: Token.data!, as: UTF8.self).contains("token") {
                // Good credentials here, as told by there being a token
                do {
                    // Parse the JSON to return token and Expiry
                    let newJson = try JSON(data: Token.data!)
                    Token.value = newJson["token"].stringValue
                    
                    // Get the expiry and attempt to convert to epoch
                    let expireString = newJson["expires"].stringValue
                    let dateFormatter = ISO8601DateFormatter()
                    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

                    // If we can convert successfully, store it to the Token object. Otherwise throw an error.
                    if let date = dateFormatter.date(from: expireString) {
                        Token.expiration = Int(date.timeIntervalSince1970 * 1000)
                    } else {
                        self.logMan.writeLog(level: .error, logString: "Failed to convert token expiry to epoch. Received \(expireString).")
                    }
                    
                } catch let error as NSError {
                    self.logMan.writeLog(level: .error, logString: "Failed to load: \(error.localizedDescription)")
                }
            }
        }
    }
    
    public func tokenRefresher() {
        let currentEpoch = Int(Date().timeIntervalSince1970 * 1000)
        
        // Find the difference between expiry time and current epoch
        let secondsToExpire = (Token.expiration! - currentEpoch)/1000
        
        if secondsToExpire <= 30 {
            logMan.writeLog(level: .info, logString: "Token only has \(secondsToExpire) seconds left to live. Refreshing token.")
            getToken(allowUntrusted: self.tokenDefaults.bool(forKey: "Insecure"))
        } else {
            logMan.writeLog(level: .info, logString: "Token has \(secondsToExpire) seconds left to live. Proceeding with current token.")
        }
    }
}


