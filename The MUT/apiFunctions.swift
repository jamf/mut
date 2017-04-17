//
//  apiFunctions.swift
//  The MUT
//
//  Created by Michael Levenick on 4/17/17.
//  Copyright © 2017 Levenick Enterprises LLC. All rights reserved.
//

import Foundation


class apiFunctions: NSObject, URLSessionDelegate {

    func verifyCredentials(endpoint: String, concatCredentials: String){
        
        let utf8Credentials = concatCredentials.data(using: String.Encoding.utf8)
        let base64Credentials = utf8Credentials?.base64EncodedString()

        
        DispatchQueue.main.async {
            //let myURL = "\(self.ApprovedURL!)activationcode"
            let myURL = "\(endpoint)activationcode"
            let encodedURL = NSURL(string: myURL)
            let request = NSMutableURLRequest(url: encodedURL! as URL)
            request.httpMethod = "GET"
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = ["Authorization" : "Basic \(base64Credentials!)", "Content-Type" : "text/xml", "Accept" : "text/xml"]
            let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
            let task = session.dataTask(with: request as URLRequest, completionHandler: {
                (data, response, error) -> Void in
                if let httpResponse = response as? HTTPURLResponse {
                    print(httpResponse.statusCode)
                }
                
                
            })
            task.resume()
        }
        
    }

}
