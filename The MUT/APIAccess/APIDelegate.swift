//
//  APIDelegate.swift
//  testProj
//
//  Created by Andrew Pirkl on 11/24/19.
//  Copyright © 2019 PIrklator. All rights reserved.
//
import Foundation

/**
    URLSessionDelegate  to ignore or force authentication to the server.
 */
public class APIDelegate: NSObject, URLSessionDelegate
{
    private var allowUntrusted: Bool = false
    
    let logMan = logManager()
    
    func setTrust(_allowUntrusted: Bool)
    {
        self.allowUntrusted = _allowUntrusted
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping(  URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if allowUntrusted {
            NSLog("[WARN  ]: The user has selected to allow untrusted SSL. MUT will not be performing SSL verification. This is potentially unsafe.")
            logMan.warnWrite(logString: "The user has selected to allow untrusted SSL. MUT will not be performing SSL verification. This is potentially unsafe.")
            completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        } else {
            completionHandler(.performDefaultHandling, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        }
    }
}
