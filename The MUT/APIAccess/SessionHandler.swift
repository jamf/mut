//
//  SessionHandler.swift
//  testProj
//
//  Created by Andrew Pirkl on 11/24/19.
//  Copyright © 2019 PIrklator. All rights reserved.
//
import Foundation

/**
 Global URLSession Handler
 */
public class SessionHandler
{
    /**
     Access singleton session handler
     */
    public static let SharedSessionHandler = SessionHandler()
    /**
     Access singleton URLSession
     */
    public let mySession: URLSession

    private let myDelQueue = OperationQueue()
    private let myDelegate = APIDelegate()
    private init()
    {
        print("initializing session")
        let config = URLSessionConfiguration.default
        config.httpMaximumConnectionsPerHost = 1
        self.mySession = URLSession(configuration: config, delegate: myDelegate, delegateQueue: myDelQueue)
    }
    /*
     Set trust for singleton. This will switch trust for queued tasks.
     */
    public func setAllowUntrusted(allowUntrusted : Bool){
        myDelegate.setTrust(_allowUntrusted: allowUntrusted)
    }
}
