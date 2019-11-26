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
    func setTrust(_allowUntrusted: Bool)
    {
        self.allowUntrusted = _allowUntrusted
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping(  URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if allowUntrusted {
            print("requiring authentication")
            completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        } else {
            print("ignoring authentication")
            completionHandler(.performDefaultHandling, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        }
    }
}
