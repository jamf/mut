//
//  JSSClient.swift
//  The MUT
//
//  Created by Michael Levenick on 11/14/16.
//  Copyright © 2016 Levenick Enterprises LLC. All rights reserved.
//

import Foundation
class JSSClient: NSObject, URLSessionDelegate {
    
    //  MARK: - Types
    
    enum Response {
        case badRequest
        case success
        case httpCode(Int)
        case json(Any)
        case xml(XMLDocument)
        case error(Error)
    }
    
    struct Credentials {
        let username: String
        let password: String
        func encodeForRequest() -> String {
            return "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
        }
    }
    
    enum DataType {
        case json, xml
    }
    
    enum HTTPMethod: CustomStringConvertible {
        case get, put, post, delete
        var description: String {
            switch self {
            case .get:      return "GET"
            case .delete:   return "DELETE"
            case .post:     return "POST"
            case .put:      return "PUT"
            }
        }
    }
    
    //  MARK: - Properties
    
    let resourceURL: URL
    let allowUntrusted: Bool
    private var queue: OperationQueue
    private var session: URLSession!
    
    //  MARK: - Public
    
    init(urlString: String, allowUntrusted allow: Bool) {
        
        //resourceURL = URL(string: urlString)!.appendingPathComponent("JSSResource")
        
        resourceURL = URL(string: urlString)!
        
        
        allowUntrusted = allow
        queue = OperationQueue()
        super.init()
        session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: queue)
    }
    
    func sendRequestAndWait(endpoint: String, method: HTTPMethod, base64credentials: String, dataType: DataType, body: Data?) -> Response {
        var response: Response!
        let semephore = DispatchSemaphore(value: 0)
        sendRequest(endpoint: endpoint, method: method, base64credentials: base64credentials, dataType: dataType, body: body, queue: DispatchQueue.global(qos: .default)) {
            response = $0
            semephore.signal()
        }
        semephore.wait()
        return response
    }
    
    func sendRequest(endpoint: String, method: HTTPMethod, base64credentials: String, dataType: DataType, body: Data?, queue: DispatchQueue, handler: @escaping (Response)->Swift.Void) {
        let url = self.resourceURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        request.httpMethod = "\(method)"
        
        var headers = ["Authorization": "Basic \(base64credentials)"]
        switch dataType {
        case .json:
            headers["Content-Type"] = "application/json"
            headers["Accept"] = "application/json"
            if let obj = body {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: obj, options: JSONSerialization.WritingOptions(rawValue: 0))
                } catch {
                    queue.async {
                        handler(.badRequest)
                    }
                    return
                }
            }
        case .xml:
            headers["Content-Type"] = "application/xml"
            headers["Accept"] = "application/xml"
            request.httpBody = body
            /*if let obj = body {
                request.httpBody = (obj as! XMLDocument).xmlData
            }*/
        }
        request.allHTTPHeaderFields = headers
        
        session.dataTask(with: request) {
            var response: Response
            if let error = $2 {
                response = .error(error)
            } else {
                let httpResponse = $1 as! HTTPURLResponse
                switch httpResponse.statusCode {
                case 200..<299:
                    if let object = try? JSONSerialization.jsonObject(with: $0!, options: JSONSerialization.ReadingOptions(rawValue: 0)) {
                        response = .json(object)
                    } else if let object = try? XMLDocument(data: $0!, options: 0) {
                        response = .xml(object)
                    } else {
                        response = .success
                    }
                default:
                    response = .httpCode(httpResponse.statusCode)
                }
            }
            
            queue.async {
                handler(response)
            }
            }.resume()
    }
    
    //  MARK: - URLSessionDelegate
    
    @nonobjc public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if allowUntrusted {
            completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
}
