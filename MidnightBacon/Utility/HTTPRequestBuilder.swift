//
//  HTTPRequestBuilder.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/14/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

class HTTPRequestBuilder {
    let URLBuilder: HTTPURLBuilder
    var defaultHeader: [String:String] = [:]
    
    convenience init(secure: Bool, host: String, path: String? = nil, port: Int? = nil) {
        self.init(URLBuilder: HTTPURLBuilder(secure: secure, host: host, path: path, port: port))
    }
    
    convenience init(baseURL: NSURL) {
        self.init(URLBuilder: HTTPURLBuilder(baseURL: baseURL))
    }
    
    init(URLBuilder: HTTPURLBuilder) {
        self.URLBuilder = URLBuilder
    }
    
    var accept : String? {
        get {
            return defaultHeader["Accept"]
        }
        set {
            defaultHeader["Accept"] = newValue
        }
    }
    
    var acceptCharset : String? {
        get {
            return defaultHeader["Accept-Charset"]
        }
        set {
            defaultHeader["Accept-Charset"] = newValue
        }
    }
    
    var acceptEncoding : String? {
        get {
            return defaultHeader["Accept-Encoding"]
        }
        set {
            defaultHeader["Accept-Encoding"] = newValue
        }
    }
    
    var acceptLanguage : String? {
        get {
            return defaultHeader["Accept-Language"]
        }
        set {
            defaultHeader["Accept-Language"] = newValue
        }
    }

    var authorization : String? {
        get {
            return defaultHeader["Authorization"]
        }
        set {
            defaultHeader["Authorization"] = newValue
        }
    }
    
    var cacheControl : String? {
        get {
            return defaultHeader["Cache-Control"]
        }
        set {
            defaultHeader["Cache-Control"] = newValue
        }
    }
    
    var connection : String? {
        get {
            return defaultHeader["Connection"]
        }
        set {
            defaultHeader["Connection"] = newValue
        }
    }
    
    var cookie : String? {
        get {
            return defaultHeader["Cookie"]
        }
        set {
            defaultHeader["Cookie"] = newValue
        }
    }
    
    var contentType : String? {
        get {
            return defaultHeader["Content-Type"]
        }
        set {
            defaultHeader["Content-Type"] = newValue
        }
    }

    var userAgent : String? {
        get {
            return defaultHeader["User-Agent"]
        }
        set {
            defaultHeader["User-Agent"] = newValue
        }
    }
    
    func GET(path: String, query: [String:String]? = nil, fragment: String? = nil, body: NSData? = nil) -> NSMutableURLRequest {
        if let URL = URLBuilder.URL(path: path, query: query, fragment: fragment) {
            return self.dynamicType.HTTPRequest("GET", URL: URL, headers: defaultHeader, body: body)
        } else {
            fatalError("Invalid URL")
        }
    }
    
    func DELETE(path: String, query: [String:String]? = nil, fragment: String? = nil, body: NSData? = nil) -> NSMutableURLRequest {
        if let URL = URLBuilder.URL(path: path, query: query, fragment: fragment) {
            return self.dynamicType.HTTPRequest("DELETE", URL: URL, headers: defaultHeader, body: body)
        } else {
            fatalError("Invalid URL")
        }
    }
    
    func PATCH(path: String, parameters: [String:String]? = nil, encoding: UInt = NSUTF8StringEncoding, query: [String:String]? = nil, fragment: String? = nil) -> NSMutableURLRequest {
        let body = self.dynamicType.formURLencoded(parameters, encoding: encoding)
        return PATCH(path, body: body, query: query, fragment: fragment)
    }
    
    func PATCH(path: String, body: NSData? = nil, query: [String:String]? = nil, fragment: String? = nil) -> NSMutableURLRequest {
        if let URL = URLBuilder.URL(path: path, query: query, fragment: fragment) {
            return self.dynamicType.HTTPRequest("PATCH", URL: URL, headers: defaultHeader, body: body)
        } else {
            fatalError("Invalid URL")
        }
    }
    
    func POST(path: String, parameters: [String:String]? = nil, encoding: UInt = NSUTF8StringEncoding, query: [String:String]? = nil, fragment: String? = nil) -> NSMutableURLRequest {
        let body = self.dynamicType.formURLencoded(parameters, encoding: encoding)
        return POST(path, body: body, query: query, fragment: fragment)
    }
    
    func POST(path: String, body: NSData? = nil, query: [String:String]? = nil, fragment: String? = nil) -> NSMutableURLRequest {
        if let URL = URLBuilder.URL(path: path, query: query, fragment: fragment) {
            return self.dynamicType.HTTPRequest("POST", URL: URL, headers: defaultHeader, body: body)
        } else {
            fatalError("Invalid URL")
        }
    }
    
    func PUT(path: String, parameters: [String:String]? = nil, encoding: UInt = NSUTF8StringEncoding, query: [String:String]? = nil, fragment: String? = nil) -> NSMutableURLRequest {
        let body = self.dynamicType.formURLencoded(parameters, encoding: encoding)
        return PUT(path, body: body, query: query, fragment: fragment)
    }
    
    func PUT(path: String, body: NSData? = nil, query: [String:String]? = nil, fragment: String? = nil) -> NSMutableURLRequest {
        if let URL = URLBuilder.URL(path: path, query: query, fragment: fragment) {
            return self.dynamicType.HTTPRequest("PUT", URL: URL, headers: defaultHeader, body: body)
        } else {
            fatalError("Invalid URL")
        }
    }
    
    class func HTTPRequest(method: String, URL: NSURL, headers headersOrNil: [String:String]? = nil, body: NSData? = nil) -> NSMutableURLRequest {
        let request = NSMutableURLRequest()
        request.HTTPMethod = method
        request.URL = URL
        request.HTTPBody = body
        
        if let headers = headersOrNil {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        return request
    }
    
    class func formURLencoded(parameters: [String:String]?, encoding: UInt = NSUTF8StringEncoding) -> NSData? {
        let components = NSURLComponents()
        components.queryItems = HTTPURLBuilder.queryItems(query: parameters)
        return components.query?.dataUsingEncoding(encoding, allowLossyConversion: false)
    }
}
