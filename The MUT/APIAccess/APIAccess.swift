//
//  APIAccess.swift
//  testProj
//
//  Created by Andrew Pirkl on 11/24/19.
//  Copyright © 2019 PIrklator. All rights reserved.
//

import Foundation
/**
 Run operations against an API
 */
public class APIAccess {
    
    /**
     Add and run a datatask by a URLRequest with the SessionHandler singleton's URLSession
     */
    func runCall(mySession: URLSession, myRequest : URLRequest,completion: @escaping (Data?,URLResponse?,Error?) -> Void)
    {
        mySession.dataTask(with: myRequest)
        { (data: Data?, response: URLResponse?, error: Error?) in
            return completion(data,response,error)
        }.resume()
    }
    
    /**
     Handle result of a dataTask
     */
    public func parseCall(data: Data?, response: URLResponse?, error: Error?) -> Void
    {
        if let error = error {
            print("got an error")
            print(error)
            return
         }
        guard let response = response else {
            print("empty response")
            return
         }
        guard let data = data else {
            print("empty data")
            return
         }
        // check for response errors, and handle data
        print("We got some data up in here")
        let responseData = String(data: data, encoding: String.Encoding.utf8)
        print((String(describing: responseData)))
    }
    
    
    public func testCall()
    {
        let creds = String("user:pass").toBase64()
        var request = URLRequest(url: URL(string: "https://tryitout.jamfcloud.com/JSSResource/computers")!)
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue("Basic \(creds)", forHTTPHeaderField: "Authorization")
        runCall(mySession: SessionHandler.SharedSessionHandler.mySession,myRequest: request)
        {data,response,error in self.parseCall(data: data,response: response,error: error)}
        
    }
}
