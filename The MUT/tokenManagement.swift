//
//  API.swift
//  The MUT v5
//
//  Created by Michael Levenick on 5/24/19.
//  Copyright © 2019 Levenick Enterprises, LLC. All rights reserved.
//

import Foundation

public class tokenManagement: NSObject {
    
    let logMan = logManager()
    let sessionHandler = SessionHandler.SharedSessionHandler

    
    // This function can be used to generate a token. Pass in a URL and base64 encoded credentials.
    // The credentials are inserted into the header.
    public func getToken(url: String, user: String, password: String, allowUntrusted: Bool) -> Data {
        let dataPrep = dataPreparation()
        
        // Call the data manipulation class to base64 encode the credentials
        let base64Credentials = dataPrep.base64Credentials(user: user, password: password)
        //print("base64 creds: " + base64Credentials) // Uncomment for debugging

        // Percent encode special characters that are not allowed in URLs, such as spaces
        let encodedURL = "\(url)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "https://null"

        // Create a URL for getting a token.
        let tokenURL = dataPrep.generateURL(baseURL: encodedURL, endpoint: "/auth/tokens", identifierType: "", identifier: "", jpapi: true, jpapiVersion: "nil")
        //print("The URL is " + tokenURL) // Uncomment for debugging
        
        // Declare a variable to be populated, and set up the HTTP Request with headers
        var token = "nil".data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        // The semaphore is what allows us to force the code to wait for this request to complete
        // Without the semaphore, MUT will queue up a request for every single line of the CSV simultaneously
        let semaphore = DispatchSemaphore(value: 0)
        let request = NSMutableURLRequest(url: tokenURL)

        // Determine the request type. If we pass this in with a variable, we could use this function for PUT as well.
        request.httpMethod = "POST"
        
        request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization" )
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
                    token = data!
                    //NSLog("[INFO  ]: Successful GET completed by The MUT.app")
                    self.logMan.infoWrite(logString: "A new token was successfully generated by MUT.  \(httpResponse.statusCode).")
                    //self.logMan.infoWrite(logString: String(decoding: token, as: UTF8.self))
                } else {
                    // Bad Response from API
                    token = data!
                    self.logMan.errorWrite(logString: "MUT Failed to generate a token.  \(httpResponse.statusCode).")
                    self.logMan.errorWrite(logString: String(decoding: token, as: UTF8.self))
                }
                semaphore.signal() // Signal completion to the semaphore
            }
            
            if error != nil {
                let errorString = "[FATAL ]: " + error!.localizedDescription
                token = errorString.data(using: .utf8)!
                //NSLog("[FATAL ]: " + error!.localizedDescription)
                self.logMan.fatalWrite(logString: error!.localizedDescription)
                semaphore.signal() // Signal completion to the semaphore
            }
        })
        task.resume() // Kick off the actual GET here
        semaphore.wait() // Wait for the semaphore before moving on to the return value
        return token
    }
    
    // This function can be used to generate a token. Pass in a URL and base64 encoded credentials.
    // The credentials are inserted into the header.
    public func renewToken(version: String, url: String, token: String, expiry: Int, allowUntrusted: Bool) -> Data {
        let dataPrep = dataPreparation()

        // Percent encode special characters that are not allowed in URLs, such as spaces
        let encodedURL = "\(url)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "https://null"

        // Create a URL for getting a token.
        let tokenURL = dataPrep.generateURL(baseURL: encodedURL, endpoint: "/auth/keep-alive", identifierType: "", identifier: "", jpapi: true, jpapiVersion: "v1")
        print("The URL used for Token Renewal is \(tokenURL)") // Uncomment for debugging
        
        // Declare a variable to be populated, and set up the HTTP Request with headers
        var datatoken = "nil".data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        // The semaphore is what allows us to force the code to wait for this request to complete
        // Without the semaphore, MUT will queue up a request for every single line of the CSV simultaneously
        let semaphore = DispatchSemaphore(value: 0)
        let request = NSMutableURLRequest(url: tokenURL)

        // Determine the request type. If we pass this in with a variable, we could use this function for PUT as well.
        request.httpMethod = "POST"
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization" )
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
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
                    datatoken = data!
                    //NSLog("[INFO  ]: Successful GET completed by The MUT.app")
                    self.logMan.infoWrite(logString: "A new token was successfully generated by MUT.  \(httpResponse.statusCode).")
                    //self.logMan.infoWrite(logString: String(decoding: token, as: UTF8.self))
                } else {
                    // Bad Response from API
                    datatoken = data!
                    self.logMan.errorWrite(logString: "MUT Failed to renew the token.  \(httpResponse.statusCode).")
                    self.logMan.errorWrite(logString: String(decoding: datatoken, as: UTF8.self))
                }
                semaphore.signal() // Signal completion to the semaphore
            }
            
            if error != nil {
                let errorString = "[FATAL ]: " + error!.localizedDescription
                datatoken = errorString.data(using: .utf8)!
                //NSLog("[FATAL ]: " + error!.localizedDescription)
                self.logMan.fatalWrite(logString: error!.localizedDescription)
                semaphore.signal() // Signal completion to the semaphore
            }
        })
        task.resume() // Kick off the actual GET here
        semaphore.wait() // Wait for the semaphore before moving on to the return value
        return datatoken
    }
    
    public func checkExpiry(expiry: Int) -> Bool {
        // Usage: let isExpired = tokenMan.checkExpiry(expiry: expiryEpoch)
        // Get current epoch time in ms
        let currentEpoch = Int(Date().timeIntervalSince1970 * 1000)
        // print(currentEpoch) // Uncomment for debugging
        // Find the difference between expiry time and current epoch
        let secondsToExpire = (expiry - currentEpoch)/1000
        //print("Expires in \(secondsToExpire) seconds") // Uncomment for debugging
        if secondsToExpire <= 30 {
            logMan.infoWrite(logString: "Token only has \(secondsToExpire) seconds left to live. Suggest getting a new token.")
            return true
        } else {
            logMan.infoWrite(logString: "Token has \(secondsToExpire) seconds left to live. Proceeding with current token.")
            return false
        }
    }
}


