//
//  HTTP.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/1/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation
import FranticApparatus

class NotHTTPResponseError : Error { }

class HTTP {
    var host: String = ""
    var secure: Bool = false
    var port: UInt = 0
    let session: PromiseURLSession
    var userAgent: String = ""
    
    init(host: String, configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()) {
        self.host = host
        self.session = PromiseURLSession(configuration: configuration)
    }
    
    func request(method: String, url: NSURL) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method
        if countElements(userAgent) > 0 {
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        }
        return request
    }
    
    func get(url: NSURL) -> NSMutableURLRequest {
        return request("GET", url: url)
    }
    
    func get(path: String = "", query: [String:String] = [:], fragment: String = "") -> NSMutableURLRequest {
        return get(url(path: path, query: query, fragment: fragment))
    }
    
    func post(url: NSURL, body: NSData? = nil) -> NSMutableURLRequest {
        let post = request("POST", url: url)
        if let nonNilBody = body {
            post.HTTPBody = nonNilBody
        }
        return post
    }
    
    func post(path: String = "", body: NSData? = nil, query: [String:String] = [:], fragment: String = "") -> NSMutableURLRequest {
        return post(url(path: path, query: query, fragment: fragment), body: body)
    }
    
    func promise(request: NSURLRequest) -> Promise<(response: NSHTTPURLResponse, data: NSData)> {
        return session.promise(request).when { (response, data) -> Result<(response: NSHTTPURLResponse, data: NSData)> in
            if let httpResponse = response as? NSHTTPURLResponse {
                return .Success((response: httpResponse, data: data))
            } else {
                return .Failure(NotHTTPResponseError())
            }
        }
    }
    
    func promiseGET(path: String = "", query: [String:String] = [:], fragment: String = "") -> Promise<(response: NSHTTPURLResponse, data: NSData)> {
        return promise(get(path: path, query: query, fragment: fragment))
    }
    
    func promisePOST(path: String = "", body: NSData? = nil, query: [String:String] = [:], fragment: String = "") -> Promise<(response: NSHTTPURLResponse, data: NSData)> {
        return promise(post(path: path, body: body, query: query, fragment: fragment))
    }
    
    func url(path: String = "", query: [String:String] = [:], fragment: String = "") -> NSURL {
        let components = NSURLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        if port > 0 {
            components.port = port
        }
        if countElements(query) > 0 {
            components.queryItems = HTTP.queryItems(query)
        }
        if countElements(fragment) > 0 {
            components.fragment = fragment
        }
        return components.URL!
    }
    
    var scheme: String {
        return secure ? "https" : "http"
    }
    
    class func formURLencoded(parameters: [String:String], encoding: UInt = NSUTF8StringEncoding) -> NSData {
        let components = NSURLComponents()
        components.queryItems = queryItems(parameters)
        if let query = components.query?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            return query
        } else {
            return NSData()
        }
    }
    
    class func queryItems(query: [String:String]) -> [NSURLQueryItem] {
        var queryItems = [NSURLQueryItem]()
        for (name, value) in query {
            queryItems.append(NSURLQueryItem(name: name, value: value))
        }
        return queryItems
    }
}
