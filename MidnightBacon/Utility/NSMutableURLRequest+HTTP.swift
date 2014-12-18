//
//  NSMutableURLRequest+HTTP.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/17/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

extension NSMutableURLRequest {
    var accept : String? {
        get {
            return valueForHTTPHeaderField("Accept")
        }
        set {
            setValue(newValue, forHTTPHeaderField: "Accept")
        }
    }
    
    var acceptCharset : String? {
        get {
            return valueForHTTPHeaderField("Accept-Charset")
        }
        set {
            setValue(newValue, forHTTPHeaderField: "Accept-Charset")
        }
    }
    
    var acceptEncoding : String? {
        get {
            return valueForHTTPHeaderField("Accept-Encoding")
        }
        set {
            setValue(newValue, forHTTPHeaderField: "Accept-Encoding")
        }
    }
    
    var acceptLanguage : String? {
        get {
            return valueForHTTPHeaderField("Accept-Language")
        }
        set {
            setValue(newValue, forHTTPHeaderField: "Accept-Language")
        }
    }
    
    var authorization : String? {
        get {
            return valueForHTTPHeaderField("Authorization")
        }
        set {
            setValue(newValue, forHTTPHeaderField: "Authorization")
        }
    }
    
    func basicAuthorization(# username: String, password: String) {
        let authorizationString = "\(username):\(password)"
        if let authorizationData = authorizationString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            let base64String = authorizationData.base64EncodedDataWithOptions(NSDataBase64EncodingOptions(0))
            authorization = "Basic \(base64String)"
        }
    }
    
    var cacheControl : String? {
        get {
            return valueForHTTPHeaderField("Cache-Control")
        }
        set {
            setValue(newValue, forHTTPHeaderField: "Cache-Control")
        }
    }
    
    var connection : String? {
        get {
            return valueForHTTPHeaderField("Connection")
        }
        set {
            setValue(newValue, forHTTPHeaderField: "Connection")
        }
    }
    
    var cookie : String? {
        get {
            return valueForHTTPHeaderField("Cookie")
        }
        set {
            setValue(newValue, forHTTPHeaderField: "Cookie")
        }
    }
    
    var contentType : MIMEType? {
        get {
            if let rawValue = valueForHTTPHeaderField("Content-Type") {
                return MIMEType(rawValue: rawValue)
            } else {
                return nil
            }
        }
        set {
            setValue(newValue?.rawValue, forHTTPHeaderField: "Content-Type")
        }
    }
    
    var userAgent : String? {
        get {
            return valueForHTTPHeaderField("User-Agent")
        }
        set {
            setValue(newValue, forHTTPHeaderField: "User-Agent")
        }
    }
    
    func GET(path: String, _ parameters: [String:String]? = nil) -> NSMutableURLRequest {
        return HTTPRequest(.GET, path: path, parameters: parameters, body: nil)
    }
    
    func POST(path: String, _ parameters: [String:String]? = nil, encoding: UInt = NSUTF8StringEncoding) -> NSMutableURLRequest {
        let request = POST(path, body: formURLEncode(parameters, encoding: encoding))
        request.contentType = .Application_X_WWW_Form_URLEncoded
        return request
    }
    
    func POST(path: String, body: NSData? = nil) -> NSMutableURLRequest {
        return HTTPRequest(.POST, path: path, parameters: nil, body: body)
    }

    func HTTPRequest(method: HTTP.Method, path: String, parameters: [String:String]? = nil, body: NSData? = nil) -> NSMutableURLRequest {
        let request = copy() as NSMutableURLRequest
        request.HTTPMethod = method.rawValue
        request.URL = request.URL?.append(path: path, parameters: parameters)
        request.HTTPBody = body
        return request
    }
}

func formURLEncode(parameters: [String:String]?, encoding: UInt = NSUTF8StringEncoding) -> NSData? {
    let components = NSURLComponents()
    components.parameters = parameters
    return components.query?.dataUsingEncoding(encoding, allowLossyConversion: false)
}
