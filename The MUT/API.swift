//
//  API.swift
//  The MUT v5
//
//  Created by Michael Levenick on 5/24/19.
//  Copyright © 2019 Michael Levenick. All rights reserved.
//

import Foundation

public class API {
    
    // This function can be used to generate a token. Pass in a URL and base64 encoded credentials.
    // The credentials are inserted into the header.
    public func verifyCredentials(url: String, user: String, password: String) -> Data {
        
        let dataMan = dataManipulation()
        
        // Call the data manipulation class to base64 encode the credentials
        let base64Credentials = dataMan.base64Credentials(user: user, password: password)
        //print("base64 creds: " + base64Credentials) // Uncomment for debugging
        
        // Create a URL for getting a token.
        let tokenURL = dataMan.generateURL(baseURL: url, endpoint: "/auth/tokens", jpapi: true, jpapiVersion: "nil")
        //print("The URL is " + tokenURL) // Uncomment for debugging
        
        // Declare a variable to be populated, and set up the HTTP Request with headers
        var token = "nil".data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        // I commented this line out because it was replacing our forward slashes.
        // I think there's an issue in Swift 5 with the "urlHostsAllowed" character set. We should investigate this
        // Because some URLs need to be percent encoded (things like spaces)
        //let encodedURL = NSURL(string: "\(url)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)! as URL
        
        // The semaphore is what allows us to force the code to wait for this request to complete
        // Without the semaphore, MUT will queue up a request for every single line of the CSV simultaneously
        let semaphore = DispatchSemaphore(value: 0)
        let request = NSMutableURLRequest(url: tokenURL)

        // Determine the request type. If we pass this in with a variable, we could use this function for PUT as well.
        request.httpMethod = "POST"
        
        // Set configuration settings for the request, such as headers
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Authorization" : "Basic \(base64Credentials)"]
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
    
    
    
    public func extendToken(url: String, user: String, password: String) -> Data {
        let dataMan = dataManipulation()
        
        let base64Credentials = dataMan.base64Credentials(user: user, password: password)
        print("base64 creds: " + base64Credentials)
        
        let tokenURL = dataMan.generateURL(baseURL: url, endpoint: "/auth/keepAlive", jpapi: true, jpapiVersion: "nil")
        print(tokenURL)
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
}
