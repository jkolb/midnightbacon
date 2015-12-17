// Copyright (c) 2016 Justin Kolb - http://franticapparatus.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public extension NSURLRequest {
    public func DELETE(path path: String, parameters: [String:String] = [:]) -> NSMutableURLRequest {
        return requestHTTPMethod(.DELETE, path: path, parameters: parameters)
    }
    
    public func GET(path path: String, parameters: [String:String] = [:]) -> NSMutableURLRequest {
        return requestHTTPMethod(.GET, path: path, parameters: parameters)
    }
    
    public func POST(path path: String, JSONObject: AnyObject) -> NSMutableURLRequest {
        return POST(path: path, body: try! NSJSONSerialization.dataWithJSONObject(JSONObject, options: []), mediaType: .ApplicationJSON)
    }
    
    public func POST(path path: String, parameters: [String:String] = [:], encoding: NSStringEncoding = NSUTF8StringEncoding) -> NSMutableURLRequest {
        return POST(path: path, body: NSData.formURLEncodeParameters(parameters, encoding: encoding), mediaType: .ApplicationXWWWFormURLEncoded)
    }
    
    public func POST(path path: String, body: NSData? = nil, mediaType: HTTPMediaType? = .ApplicationOctetStream) -> NSMutableURLRequest {
        return requestHTTPMethod(.POST, path: path, parameters: [:], body: body, mediaType: mediaType)
    }

    public func PUT(path path: String, JSONObject: AnyObject) -> NSMutableURLRequest {
        return PUT(path: path, body: try! NSJSONSerialization.dataWithJSONObject(JSONObject, options: []), mediaType: .ApplicationJSON)
    }

    public func PUT(path path: String, parameters: [String:String] = [:], encoding: NSStringEncoding = NSUTF8StringEncoding) -> NSMutableURLRequest {
        return PUT(path: path, body: NSData.formURLEncodeParameters(parameters, encoding: encoding), mediaType: .ApplicationXWWWFormURLEncoded)
    }
    
    public func PUT(path path: String, body: NSData? = nil, mediaType: HTTPMediaType? = nil) -> NSMutableURLRequest {
        return requestHTTPMethod(.PUT, path: path, parameters: [:], body: body, mediaType: mediaType)
    }
    
    public func requestHTTPMethod(method: HTTPRequestMethod, path: String, parameters: [String:String] = [:], body: NSData? = nil, mediaType: HTTPMediaType? = nil) -> NSMutableURLRequest {
        return requestHTTPMethod(method.rawValue, path: path, parameters: parameters, body: body, contentType: mediaType?.rawValue)
    }
    
    public func requestHTTPMethod(method: String, path: String, parameters: [String:String] = [:], body: NSData? = nil, contentType: String? = nil) -> NSMutableURLRequest {
        let request = mutableCopy() as! NSMutableURLRequest
        request.URL = request.URL?.relativeToPath(path, parameters: parameters)
        request.HTTPMethod = method
        request.HTTPBody = body
        request[.ContentType] = contentType
        request.contentLength = body?.length
        return request
    }
}

public enum AuthenticationError : ErrorType {
    case UnableToEncodeAuthorizationString
}

public extension NSMutableURLRequest {
    public func basicAuthorization(username username: String, password: String, encoding: NSStringEncoding = NSUTF8StringEncoding) throws {
        let authorizationString = "\(username):\(password)"
        
        guard let authorizationData = authorizationString.dataUsingEncoding(encoding, allowLossyConversion: false) else {
            throw AuthenticationError.UnableToEncodeAuthorizationString
        }
        
        let base64String = authorizationData.base64EncodedStringWithOptions([])
        self[.Authorization] = "Basic \(base64String)"
    }

    public var method : HTTPRequestMethod? {
        get {
            return HTTPRequestMethod(rawValue: HTTPMethod)
        }
        set {
            HTTPMethod = newValue?.rawValue ?? ""
        }
    }
    
    public var contentType : HTTPMediaType? {
        get {
            if let rawValue = self[.ContentType] {
                return HTTPMediaType(rawValue: rawValue)
            }
            else {
                return nil
            }
        }
        set {
            self[.ContentType] = newValue?.rawValue
        }
    }
    
    public var contentLength : Int? {
        get {
            if let value = self[.ContentLength] {
                return Int(value)
            }
            else {
                return nil
            }
        }
        set {
            if let value = newValue {
                let string = String(value)
                self[.ContentLength] = string
            }
            else {
                self[.ContentLength] = nil
            }
        }
    }
    
    public subscript(field: HTTPRequestField) -> String? {
        get {
            return self[field.rawValue]
        }
        set {
            self[field.rawValue] = newValue
        }
    }
    
    public subscript(field: String) -> String? {
        get {
            return valueForHTTPHeaderField(field)
        }
        set {
            setValue(newValue, forHTTPHeaderField: field)
        }
    }
    
    public func addValue(value: String, forHTTPHeaderField field: HTTPRequestField) {
        addValue(value, forHTTPHeaderField: field.rawValue)
    }
}
