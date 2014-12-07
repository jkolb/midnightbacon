//
//  HTTP.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/1/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation
import FranticApparatus
import ModestProposal

class HTTP {
    var host: String = ""
    var secure: Bool = false
    var port: UInt = 0
    let factory: URLPromiseFactory
    var userAgent: String = ""
    var defaultHeaders: [String:String] = [:]
    var parseQueue: DispatchQueue = GCDQueue.globalPriorityDefault()
    
    init(factory: URLPromiseFactory = URLSessionPromiseFactory()) {
        self.factory = factory
    }
    
    func parseImage(data: NSData) -> ParseResult<UIImage> {
        if let image = UIImage(data: data) {
            return .Success(image)
        } else {
            return .Failure(UnexpectedImageFormatError())
        }
    }

    func imageValidator(response: NSHTTPURLResponse) -> Validator {
        return response.imageValidator()
    }
    
    func requestImage(url: NSURL) -> Promise<UIImage> {
        return requestImage(NSURLRequest(URL: url))
    }
    
    func requestImage(request: NSURLRequest) -> Promise<UIImage> {
        return requestContent(request, validator: imageValidator, parser: parseImage)
    }
    
    func parseJSON(data: NSData) -> ParseResult<JSON> {
        var error: NSError?
        
        if let json = JSON.parse(data, options: NSJSONReadingOptions(0), error: &error) {
            return .Success(json)
        } else {
            return .Failure(NSErrorWrapperError(cause: error!))
        }
    }

    func JSONValidator(response: NSHTTPURLResponse) -> Validator {
        return response.JSONValidator()
    }
    
    func requestJSON(path: String, query: [String:String] = [:]) -> Promise<JSON> {
        return requestJSON(get(path: path, query: query))
    }
    
    func requestJSON(request: NSURLRequest) -> Promise<JSON> {
        return requestContent(request, validator: JSONValidator, parser: parseJSON)
    }

    func requestContent<ContentType>(request: NSURLRequest, validator: (NSHTTPURLResponse) -> Validator, parser: (NSData) -> ParseResult<ContentType>) -> Promise<ContentType> {
        let queue = parseQueue
        return promise(request).when { (response, data) in
//            println(response)
            if let error = validator(response).validate() {
                println(NSString(data: data, encoding: NSUTF8StringEncoding))
                return .Failure(error)
            } else {
                return .Deferred(asyncParse(on: queue, input: data, parser: parser))
            }
        }
    }
    
    func request(method: String, url: NSURL, body: NSData? = nil) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method
        if let nonNilBody = body {
            request.HTTPBody = nonNilBody
        }
        if countElements(userAgent) > 0 {
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        }
        for (name, value) in defaultHeaders {
            request.setValue(value, forHTTPHeaderField: name)
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
        return request("POST", url: url, body: body)
    }
    
    func post(path: String = "", body: NSData? = nil, query: [String:String] = [:], fragment: String = "") -> NSMutableURLRequest {
        return post(url(path: path, query: query, fragment: fragment), body: body)
    }
    
    func promise(request: NSURLRequest) -> Promise<(response: NSHTTPURLResponse, data: NSData)> {
        return factory.promise(request).when { (response, data) -> Result<(response: NSHTTPURLResponse, data: NSData)> in
            if let httpResponse = response as? NSHTTPURLResponse {
                return .Success((response: httpResponse, data: data))
            } else {
                return .Failure(NotHTTPResponseError())
            }
        }
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
    
    func clearAllCookies() {
        let cookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let cookies = cookieStorage.cookies as? [NSHTTPCookie] {
            for cookie in cookies {
                cookieStorage.deleteCookie(cookie)
            }
        }
    }
    
    class func formURLencoded(parameters: [String:String], encoding: UInt = NSUTF8StringEncoding) -> NSData {
        let components = NSURLComponents()
        components.queryItems = queryItems(parameters)
        if let query = components.query?.dataUsingEncoding(encoding, allowLossyConversion: false) {
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
