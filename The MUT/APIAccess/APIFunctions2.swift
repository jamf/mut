//
//  API.swift
//  The MUT
//
//  Created by Andrew Pirkl on 11/25/19
//  Abstracted from APIFunctions by Benjamin Whitis on 6/14/19.
//  Copyright © 2019 Levenick Enterprises, LLC. All rights reserved.
//

import Foundation
import Cocoa

/**
 APIFunctions using SessionHandler for a global URLSession
 */
public class APIFunctions {
    
    let dataPrep = dataPreparation()
    let logMan = logManager()
    // set sessionHandler to SessionHandler singleton for easy access
    let sessionHandler = SessionHandler.SharedSessionHandler
    
    public func putData(passedUrl: String, credentials: String, endpoint: String, identifierType: String, identifier: String, allowUntrusted: Bool, xmlToPut: Data) -> (code: Int, body: Data?) {
        
        var responseCode = 400
        
        var responseBody: Data?
        
        let baseURL = dataPrep.generateURL(baseURL: passedUrl, endpoint: endpoint, identifierType: identifierType, identifier: identifier, jpapi: false, jpapiVersion: "")
        
        let encodedURL = NSURL(string: "\(baseURL)")! as URL
        logMan.infoWrite(logString: "Submitting a PUT to \(encodedURL.absoluteString)")
        // Changed to use SessionHandler to configure trust
        sessionHandler.setAllowUntrusted(allowUntrusted: allowUntrusted)
        // The semaphore is what allows us to force the code to wait for this request to complete
        // Without the semaphore, MUT will queue up a request for every single line of the CSV simultaneously
        let semaphore = DispatchSemaphore(value: 0)
        let request = NSMutableURLRequest(url: encodedURL)
        
        // Determine the request type. If we pass this in with a variable, we could use this function for PUT as well.
        request.httpMethod = "PUT"
        request.httpBody = xmlToPut
        // add headers to request for content-type and authorization since not using URLSession headers
        request.addValue("Basic \(credentials)", forHTTPHeaderField: "Authorization" )
        request.addValue("text/xml", forHTTPHeaderField: "Content-Type")
        // set session to use
        let session = sessionHandler.mySession
        
        // Completion handler. This is what ensures that the response is good/bad
        // and also what handles the semaphore
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            if let httpResponse = response as? HTTPURLResponse {
                responseCode = httpResponse.statusCode
                if httpResponse.statusCode >= 199 && httpResponse.statusCode <= 299 {
                    // Good response from API
                    self.logMan.infoWrite(logString: "Successful PUT completed. \(httpResponse.statusCode).")
                    self.logMan.infoWrite(logString: String(decoding: data!, as: UTF8.self))
                } else {
                    // Bad Response from API
                    self.logMan.errorWrite(logString: "Failed PUT. \(httpResponse.statusCode).")
                    self.logMan.errorWrite(logString: String(decoding: data!, as: UTF8.self)) // ADVANCED DEBUGGING
                }
                responseBody = data
                semaphore.signal() // Signal completion to the semaphore
            }
            
            if error != nil {
                self.logMan.fatalWrite(logString: error!.localizedDescription)
                semaphore.signal() // Signal completion to the semaphore
                
            }
        })
        task.resume() // Kick off the actual GET here
        semaphore.wait() // Wait for the semaphore before moving on to the return value
        return (responseCode, responseBody)
    }
    
    public func patchData(passedUrl: String, token: String, endpoint: String, endpointVersion: String, identifier: String, allowUntrusted: Bool, jsonData: Data) -> Int {
        var responseCode = 400
        let encodedURL = dataPrep.generateJpapiURL(baseURL: passedUrl, endpoint: endpoint, endpointVersion: endpointVersion, identifier: identifier)
        
        //logMan.infoWrite(logString: "Submitting a PATCH to \(encodedURL.absoluteString)") // Re-enable these in debug mode when available.
        //logMan.infoWrite(logString: String(decoding: jsonData, as: UTF8.self)) // Re-enable these in debug mode when available.
        // Changed to use SessionHandler to configure trust
        sessionHandler.setAllowUntrusted(allowUntrusted: allowUntrusted)
        // The semaphore is what allows us to force the code to wait for this request to complete
        // Without the semaphore, MUT will queue up a request for every single line of the CSV simultaneously
        let semaphore = DispatchSemaphore(value: 0)
        let request = NSMutableURLRequest(url: encodedURL)
        
        request.httpMethod = "PATCH"
        request.httpBody = jsonData
        // add headers to request for content-type and authorization since not using URLSession headers
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization" )
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // set session to use
        let session = sessionHandler.mySession
        // Completion handler. This is what ensures that the response is good/bad
        // and also what handles the semaphore
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            if let httpResponse = response as? HTTPURLResponse {
                responseCode = httpResponse.statusCode
                if httpResponse.statusCode >= 199 && httpResponse.statusCode <= 299 {
                    // Good response from API
                    self.logMan.infoWrite(logString: "Successful name enforcement request. \(httpResponse.statusCode).")
                    // DEBUGGING
                    //self.logMan.infoWrite(logString: String(decoding: data!, as: UTF8.self))
                } else {
                    // Bad Response from API
                    self.logMan.errorWrite(logString: "Failed name enforcement request. \(httpResponse.statusCode).")
                    self.logMan.errorWrite(logString: String(decoding: data!, as: UTF8.self))
                }
                semaphore.signal() // Signal completion to the semaphore
            }
            
            if error != nil {
                self.logMan.fatalWrite(logString: error!.localizedDescription)
                semaphore.signal() // Signal completion to the semaphore
                
            }
        })
        task.resume() // Kick off the actual PATCH here
        semaphore.wait() // Wait for the semaphore before moving on to the return value
        return responseCode
    }
    
    public func getData(passedUrl: String, token: String, endpoint: String, endpointVersion: String, identifier: String, allowUntrusted: Bool) -> (code: Int, body: Data?) {
        
        var responseCode = 400
        var responseBody: Data?
        
        let encodedURL = dataPrep.generateJpapiURL(baseURL: passedUrl, endpoint: endpoint, endpointVersion: endpointVersion, identifier: identifier)
        
        logMan.infoWrite(logString: "Submitting a GET to \(encodedURL.absoluteString)")
        // Changed to use SessionHandler to configure trust
        sessionHandler.setAllowUntrusted(allowUntrusted: allowUntrusted)
        // The semaphore is what allows us to force the code to wait for this request to complete
        // Without the semaphore, MUT will queue up a request for every single line of the CSV simultaneously
        let semaphore = DispatchSemaphore(value: 0)
        let request = NSMutableURLRequest(url: encodedURL)
        request.httpMethod = "GET"
        // add headers to request for content-type and authorization since not using URLSession headers
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization" )
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // set session to use
        let session = sessionHandler.mySession
        // Completion handler. This is what ensures that the response is good/bad
        // and also what handles the semaphore
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            if let httpResponse = response as? HTTPURLResponse {
                responseCode = httpResponse.statusCode
                if httpResponse.statusCode >= 199 && httpResponse.statusCode <= 299 {
                    // Good response from API
                    self.logMan.infoWrite(logString: "Successful GET completed. \(httpResponse.statusCode).")
                    // DEBUGGING
                    //self.logMan.infoWrite(logString: String(decoding: data!, as: UTF8.self))
                } else {
                    // Bad Response from API
                    self.logMan.errorWrite(logString: "Failed PATCH. \(httpResponse.statusCode).")
                    self.logMan.errorWrite(logString: String(decoding: data!, as: UTF8.self))
                }
                responseBody = data
                semaphore.signal() // Signal completion to the semaphore
            }
            
            if error != nil {
                self.logMan.fatalWrite(logString: error!.localizedDescription)
                semaphore.signal() // Signal completion to the semaphore
                
            }
        })
        task.resume() // Kick off the actual PATCH here
        semaphore.wait() // Wait for the semaphore before moving on to the return value
        return (responseCode, responseBody)
    }
    
    public func getPrestageScope(passedUrl: URL, token: String, endpoint: String, allowUntrusted: Bool) -> Data {
        
        logMan.infoWrite(logString: "Getting current prestage scope from \(passedUrl.absoluteString)")
        // Changed to use SessionHandler to configure trust
        sessionHandler.setAllowUntrusted(allowUntrusted: allowUntrusted)
        var globalResponse = "nil".data(using: String.Encoding.utf8, allowLossyConversion: false)!        // The semaphore is what allows us to force the code to wait for this request to complete
        // Without the semaphore, MUT will queue up a request for every single line of the CSV simultaneously
        let semaphore = DispatchSemaphore(value: 0)
        let request = NSMutableURLRequest(url: passedUrl)
        
        // Determine the request type. If we pass this in with a variable, we could use this function for PUT as well.
        request.httpMethod = "GET"
        // add headers to request for content-type and authorization since not using URLSession headers
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization" )
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // set session to use
        let session = sessionHandler.mySession
        
        // Completion handler. This is what ensures that the response is good/bad
        // and also what handles the semaphore
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode >= 199 && httpResponse.statusCode <= 299 {
                    // Good response from API
                    globalResponse = data!
                    self.logMan.infoWrite(logString: "Successful GET completed. \(httpResponse.statusCode).")
                    //self.logMan.infoWrite(logString: String(decoding: data!, as: UTF8.self))
                } else {
                    // Bad Response from API
                    globalResponse = data!
                    self.logMan.errorWrite(logString: "Failed GET. \(httpResponse.statusCode).")
                    self.logMan.errorWrite(logString: String(decoding: data!, as: UTF8.self)) // ADVANCED DEBUGGING
                }
                semaphore.signal() // Signal completion to the semaphore
            }
            
            if error != nil {
                globalResponse = data!
                self.logMan.fatalWrite(logString: error!.localizedDescription)
                semaphore.signal() // Signal completion to the semaphore
                
            }
        })
        task.resume() // Kick off the actual GET here
        semaphore.wait() // Wait for the semaphore before moving on to the return value
        return globalResponse
    }
    
    // HTTP method DELETE no longer supported for prestage updates. must use /scope/delete-multiple URL
    public func updatePrestage(passedUrl: String, endpoint: String, prestageID: String, jpapiVersion: String, token: String, jsonToSubmit: Data, httpMethod: String, allowUntrusted: Bool) -> Int {
        var returnCode = 400
        
        let baseURL = dataPrep.generatePrestageURL(baseURL: passedUrl, endpoint: endpoint, prestageID: prestageID, jpapiVersion: jpapiVersion, httpMethod: httpMethod)
        
        let encodedURL = NSURL(string: "\(baseURL)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "https://null")! as URL
        logMan.infoWrite(logString: "Updating the current prestage scope at \(encodedURL.absoluteString)")
        // Changed to use SessionHandler to configure trust
        sessionHandler.setAllowUntrusted(allowUntrusted: allowUntrusted)
        var globalResponse = "nil".data(using: String.Encoding.utf8, allowLossyConversion: false)!        // The semaphore is what allows us to force the code to wait for this request to complete
        // Without the semaphore, MUT will queue up a request for every single line of the CSV simultaneously
        let semaphore = DispatchSemaphore(value: 0)
        let request = NSMutableURLRequest(url: encodedURL)
        
        // Determine the request type. If we pass this in with a variable, we could use this function for PUT as well.
        request.httpMethod = httpMethod
        
        // DELETE is no longer supported for prestages
        if (endpoint == "computer-prestages" || endpoint == "mobile-device-prestages" ) && httpMethod == "DELETE" {
            request.httpMethod = "POST"
        }
        
        request.httpBody = jsonToSubmit
        // add headers to request for content-type and authorization since not using URLSession headers
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization" )
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // set session to use
        let session = sessionHandler.mySession
        
        // Completion handler. This is what ensures that the response is good/bad
        // and also what handles the semaphore
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            if let httpResponse = response as? HTTPURLResponse {
                returnCode = httpResponse.statusCode
                if httpResponse.statusCode >= 199 && httpResponse.statusCode <= 299 {
                    // Good response from API
                    globalResponse = data!
                    self.logMan.infoWrite(logString: "Successful scope update completed. \(httpResponse.statusCode).")
                    //self.logMan.infoWrite(logString: String(decoding: data!, as: UTF8.self))
                } else {
                    // Bad Response from API
                    globalResponse = data!
                    self.logMan.errorWrite(logString: "Failed scope update. \(httpResponse.statusCode).")
                    self.logMan.errorWrite(logString: String(decoding: data!, as: UTF8.self)) // ADVANCED DEBUGGING
                }
                semaphore.signal() // Signal completion to the semaphore
            }
            
            if error != nil {
                globalResponse = data!
                self.logMan.fatalWrite(logString: error!.localizedDescription)
                semaphore.signal() // Signal completion to the semaphore
                
            }
        })
        task.resume() // Kick off the actual GET here
        semaphore.wait() // Wait for the semaphore before moving on to the return value
        return returnCode
    }
    // removing urlSession func since now using global URLSession
}
