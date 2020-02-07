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
public class APIFunctions2 {

    let dataPrep = dataPreparation()
    let logMan = logManager()
    // set sessionHandler to SessionHandler singleton for easy access
    let sessionHandler = SessionHandler.SharedSessionHandler
    
    public func putData(passedUrl: String, credentials: String, endpoint: String, identifierType: String, identifier: String, allowUntrusted: Bool, xmlToPut: Data) -> Int {
        
        var returnCode = 400

        let baseURL = dataPrep.generateURL(baseURL: passedUrl, endpoint: endpoint, identifierType: identifierType, identifier: identifier, jpapi: false, jpapiVersion: "")

        let encodedURL = NSURL(string: "\(baseURL)")! as URL
        logMan.infoWrite(logString: "Submitting a PUT to \(encodedURL.absoluteString)")
        // Changed to use SessionHandler to configure trust
        sessionHandler.setAllowUntrusted(allowUntrusted: allowUntrusted)
        var globalResponse = ""
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
                returnCode = httpResponse.statusCode
                if httpResponse.statusCode >= 199 && httpResponse.statusCode <= 299 {
                    // Good response from API
                    globalResponse = response?.description ?? "nil"
                    self.logMan.infoWrite(logString: "Successful PUT completed. \(httpResponse.statusCode).")
                    self.logMan.infoWrite(logString: String(decoding: data!, as: UTF8.self))
                } else {
                    // Bad Response from API
                    globalResponse = response?.description ?? "nil"
                    self.logMan.errorWrite(logString: "Failed PUT. \(httpResponse.statusCode).")
                    self.logMan.errorWrite(logString: String(decoding: data!, as: UTF8.self)) // ADVANCED DEBUGGING
                }
                semaphore.signal() // Signal completion to the semaphore
            }
            
            if error != nil {
                let errorString = "[FATAL ]: " + error!.localizedDescription
                globalResponse = errorString
                self.logMan.fatalWrite(logString: error!.localizedDescription)
                semaphore.signal() // Signal completion to the semaphore
                
            }
        })
        task.resume() // Kick off the actual GET here
        semaphore.wait() // Wait for the semaphore before moving on to the return value
        return returnCode
    }

    public func enforceName(passedUrl: String, credentials: String, allowUntrusted: Bool, xmlToPost: Data) -> String {

        let baseURL = dataPrep.generateURL(baseURL: passedUrl, endpoint: "mobiledevicecommands", identifierType: "command", identifier: "DeviceName", jpapi: false, jpapiVersion: "")

        let encodedURL = NSURL(string: "\(baseURL)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "https://null")! as URL
        logMan.infoWrite(logString: "Submitting a POST to \(encodedURL.absoluteString).")
        sessionHandler.setAllowUntrusted(allowUntrusted: allowUntrusted)
        var globalResponse = ""
        // The semaphore is what allows us to force the code to wait for this request to complete
        // Without the semaphore, MUT will queue up a request for every single line of the CSV simultaneously
        let semaphore = DispatchSemaphore(value: 0)
        let request = NSMutableURLRequest(url: encodedURL)

        // Determine the request type. If we pass this in with a variable, we could use this function for PUT as well.
        request.httpMethod = "POST"
        request.httpBody = xmlToPost
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
                if httpResponse.statusCode >= 199 && httpResponse.statusCode <= 299 {
                    // Good response from API
                    globalResponse = response?.description ?? "nil"
                    self.logMan.infoWrite(logString: "Successful POST completed. \(httpResponse.statusCode).")
                    self.logMan.infoWrite(logString: String(decoding: data!, as: UTF8.self))
                } else {
                    // Bad Response from API
                    globalResponse = response?.description ?? "nil"
                    self.logMan.errorWrite(logString: "Failed POST. \(httpResponse.statusCode).")
                    //self.logMan.errorWrite(logString: String(decoding: data!, as: UTF8.self)) // ADVANCED DEBUGGING
                }
                semaphore.signal() // Signal completion to the semaphore
            }

            if error != nil {
                let errorString = "[FATAL ]: " + error!.localizedDescription
                globalResponse = errorString
                self.logMan.fatalWrite(logString: error!.localizedDescription)
                semaphore.signal() // Signal completion to the semaphore

            }
        })
        task.resume() // Kick off the actual GET here
        semaphore.wait() // Wait for the semaphore before moving on to the return value
        return globalResponse
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
        request.addValue("text/xml", forHTTPHeaderField: "Content-Type")
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
    
    public func updatePrestage(passedUrl: String, endpoint: String, prestageID: String, jpapiVersion: String, token: String, jsonToSubmit: Data, httpMethod: String, allowUntrusted: Bool) -> Int {

        var returnCode = 400

        let baseURL = dataPrep.generatePrestageURL(baseURL: passedUrl, endpoint: endpoint, prestageID: prestageID, jpapiVersion: jpapiVersion)
        
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
        request.httpBody = jsonToSubmit
        // add headers to request for content-type and authorization since not using URLSession headers
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization" )
        request.addValue("text/xml", forHTTPHeaderField: "Content-Type")
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
