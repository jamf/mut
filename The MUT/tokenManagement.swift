//
//  API.swift
//  The MUT v5
//
//  Created by Michael Levenick on 5/24/19.
//  Copyright © 2019 Michael Levenick. All rights reserved.
//

import Foundation

public class tokenManagement: NSObject, URLSessionDelegate {
    
    var allowUntrustedFlag: Bool!
    
    // This function can be used to generate a token. Pass in a URL and base64 encoded credentials.
    // The credentials are inserted into the header.
    public func getToken(url: String, user: String, password: String, allowUntrusted: Bool) -> Data {
        
        allowUntrustedFlag = allowUntrusted
        let myOpQueue = OperationQueue()
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
        
        // Set configuration settings for the request, such as headers
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Authorization" : "Basic \(base64Credentials)"]
        let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: myOpQueue)
        
        // Completion handler. This is what ensures that the response is good/bad
        // and also what handles the semaphore
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode >= 199 && httpResponse.statusCode <= 299 {
                    // Good response from API
                    token = data!
                    NSLog("[INFO  ]: Successful GET completed by The MUT.app")
                    NSLog("[INFO  ]: " + response.debugDescription)
                } else {
                    // Bad Response from API
                    token = data!
                    NSLog("[ERROR ]: Failed GET completed by The MUT.app")
                    NSLog("[ERROR ]: " + response.debugDescription)
                }
                semaphore.signal() // Signal completion to the semaphore
            }
            
            if error != nil {
                let errorString = "[FATAL ]: " + error!.localizedDescription
                token = errorString.data(using: .utf8)!
                NSLog("[FATAL ]: " + error!.localizedDescription)
                semaphore.signal() // Signal completion to the semaphore
            }
        })
        task.resume() // Kick off the actual GET here
        semaphore.wait() // Wait for the semaphore before moving on to the return value
        return token
    }
    
    public func checkExpiry(expiry: Int) -> Bool {
        // Usage: let isExpired = tokenMan.checkExpiry(expiry: expiryEpoch)
        // Get current epoch time in ms
        let currentEpoch = Int(Date().timeIntervalSince1970 * 1000)
        // print(currentEpoch) // Uncomment for debugging
        // Find the difference between expiry time and current epoch
        let secondsToExpire = (expiry - currentEpoch)/1000
        // print("Expires in \(secondsToExpire) seconds") // Uncomment for debugging
        if secondsToExpire <= 30 {
            return true
        } else {
            return false
        }
    }

    public func renewToken(url: String, user: String, password: String) -> Data {
        let dataPrep = dataPreparation()
        
        let base64Credentials = dataPrep.base64Credentials(user: user, password: password)
        let tokenURL = dataPrep.generateURL(baseURL: url, endpoint: "/auth/keepAlive", identifierType: "", identifier: "", jpapi: true, jpapiVersion: "nil")
        // Declare a variable to be populated, and set up the HTTP Request with headers
        var token = "nil".data(using: String.Encoding.utf8, allowLossyConversion: false)!
        //let encodedURL = NSURL(string: "\(url)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)! as URL
        let semaphore = DispatchSemaphore(value: 0)
        let request = NSMutableURLRequest(url: tokenURL)
        request.httpMethod = "POST"
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Authorization" : "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdXRoZW50aWNhdGVkLWFwcCI6IkdFTkVSSUMiLCJhdXRoZW50aWNhdGlvbi10eXBlIjoiSlNTIiwiZ3JvdXBzIjpbXSwic3ViamVjdC10eXBlIjoiSlNTX1VTRVJfSUQiLCJ0b2tlbi11dWlkIjoiMjY2YjI3MDUtZWYxNy00OGMzLTgzYjktOGM0ZmJjY2ViNzM4IiwibGRhcC1zZXJ2ZXItaWQiOi0xLCJzdWIiOiIyIiwiZXhwIjoxNTU4NzI5MjAwfQ.KMaIVqeiRlmdryuUNyYBy43R3B73JjnF7yOp0kbuZRM"]
        let session = Foundation.URLSession(configuration: configuration)
        
        // Completion handler. This is what ensures that the response is good/bad
        // and also what handles the semaphore
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode >= 199 && httpResponse.statusCode <= 299 {
                    // Good response from API
                    token = data!
                    NSLog("[INFO  ]: Successful GET completed by The MUT.app")
                    NSLog("[INFO  ]: " + response.debugDescription)
                } else {
                    // Bad Response from API
                    token = data!
                    NSLog("[ERROR ]: Failed GET completed by The MUT.app")
                    NSLog("[ERROR ]: " + response.debugDescription)
                }
                semaphore.signal() // Signal completion to the semaphore
            }
            
            if error != nil {
                NSLog("[FATAL ]: " + error!.localizedDescription)
            }
        })
        task.resume() // Kick off the actual GET here
        semaphore.wait() // Wait for the semaphore before moving on to the return value
        return token
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping(  URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if allowUntrustedFlag {
            NSLog("[WARN  ]: The user has selected to allow untrusted SSL. MUT will not be performing SSL verification. This is potentially unsafe.")
            completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        } else {
            // NSLog("[INFO  ]: MUT is using default SSL handling.") // Commenting this to not clutter logs of default SSL handing users
            completionHandler(.performDefaultHandling, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        }
    }
}


