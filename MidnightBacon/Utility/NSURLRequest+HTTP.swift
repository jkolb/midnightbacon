//
//  NSMutableURLRequest+HTTP.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/17/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

extension NSURLRequest {
    func GET(path: String, _ parameters: [String:String]? = nil) -> NSMutableURLRequest {
        return buildHTTP(.GET, path: path, parameters: parameters)
    }
    
    func POST(path: String, _ parameters: [String:String]? = nil, encoding: UInt = NSUTF8StringEncoding) -> NSMutableURLRequest {
        return POST(path, body: NSData.formURLEncode(parameters, encoding: encoding), contentType: .ApplicationXWWWFormURLEncoded)
    }
    
    func POST(path: String, body: NSData? = nil, contentType: MediaType? = nil) -> NSMutableURLRequest {
        return buildHTTP(.POST, path: path, parameters: nil, body: body, contentType: contentType)
    }
    
    func PUT(path: String, _ parameters: [String:String]? = nil, encoding: UInt = NSUTF8StringEncoding) -> NSMutableURLRequest {
        return PUT(path, body: NSData.formURLEncode(parameters, encoding: encoding), contentType: .ApplicationXWWWFormURLEncoded)
    }
    
    func PUT(path: String, body: NSData? = nil, contentType: MediaType? = nil) -> NSMutableURLRequest {
        return buildHTTP(.PUT, path: path, parameters: nil, body: body, contentType: contentType)
    }
    
    func buildHTTP(method: HTTP.Method, path: String, parameters: [String:String]? = nil, body: NSData? = nil, contentType: MediaType? = nil) -> NSMutableURLRequest {
        let request = mutableCopy() as NSMutableURLRequest
        request.method = method
        request.URL = request.URL?.buildURL(path: path, parameters: parameters)
        request.HTTPBody = body
        request.contentType = contentType
        request.contentLength = body?.length
        return request
    }
}

extension NSMutableURLRequest {
    func basicAuthorization(# username: String, password: String, encoding: NSStringEncoding = NSUTF8StringEncoding) {
        let authorizationString = "\(username):\(password)"
        if let authorizationData = authorizationString.dataUsingEncoding(encoding, allowLossyConversion: false) {
            let base64String = authorizationData.base64EncodedDataWithOptions(nil)
            self[.Authorization] = "Basic \(base64String)"
        } else {
            fatalError("Unable to encode string")
        }
    }

    var method : HTTP.Method? {
        get {
            return HTTP.Method(rawValue: HTTPMethod)
        }
        set {
            HTTPMethod = newValue?.rawValue ?? ""
        }
    }
    
    var contentType : MediaType? {
        get {
            if let rawValue = self[.ContentType] {
                return MediaType(rawValue: rawValue)
            } else {
                return nil
            }
        }
        set {
            self[.ContentType] = newValue?.rawValue
        }
    }
    
    var contentLength : Int? {
        get {
            return self[.ContentLength]?.toInt()
        }
        set {
            if let value = newValue {
                let string = String(value)
                self[.ContentLength] = string
            } else {
                self[.ContentLength] = nil
            }
        }
    }
    
    subscript(field: HTTP.RequestField) -> String? {
        get {
            return valueForHTTPHeaderField(field.rawValue)
        }
        set {
            setValue(newValue, forHTTPHeaderField: field.rawValue)
        }
    }
    
    subscript(field: String) -> String? {
        get {
            return valueForHTTPHeaderField(field)
        }
        set {
            setValue(newValue, forHTTPHeaderField: field)
        }
    }
    
    func addValue(value: String?, forHTTPHeaderField field: HTTP.RequestField) {
        addValue(value, forHTTPHeaderField: field.rawValue)
    }
}
