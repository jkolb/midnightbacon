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

public enum HTTPError : ErrorType {
    case UnexpectedResponse(NSURLResponse)
    case UnexpectedStatusCode(Int)
    case UnexpectedContentType(String?)
}

public extension NSURLResponse {
    public var isHTTP : Bool {
        return self is NSHTTPURLResponse
    }
    
    public var HTTP : NSHTTPURLResponse {
        return self as! NSHTTPURLResponse
    }
    
    public func validateIsHTTP(statusCode statusCode: Int, contentType: String) throws {
        try validate(when: isHTTP, otherwise: HTTPError.UnexpectedResponse(self))
        try validate(when: HTTP.statusCode == statusCode, otherwise: HTTPError.UnexpectedStatusCode(HTTP.statusCode))
        try validate(when: HTTP.MIMEType == contentType, otherwise: HTTPError.UnexpectedContentType(HTTP.MIMEType))
    }
    
    public func validateIsHTTP(statusCode statusCode: Int, contentType: HTTPMediaType) throws {
        try validate(when: isHTTP, otherwise: HTTPError.UnexpectedResponse(self))
        try validate(when: HTTP.statusCode == statusCode, otherwise: HTTPError.UnexpectedStatusCode(HTTP.statusCode))
        try validate(when: HTTP.MIMEType == contentType.rawValue, otherwise: HTTPError.UnexpectedContentType(HTTP.MIMEType))
    }
    
    public func validateIsHTTP(statusCode statusCode: HTTPStatusCode, contentType: HTTPMediaType) throws {
        try validate(when: isHTTP, otherwise: HTTPError.UnexpectedResponse(self))
        try validate(when: HTTP.statusCode == statusCode.rawValue, otherwise: HTTPError.UnexpectedStatusCode(HTTP.statusCode))
        try validate(when: HTTP.MIMEType == contentType.rawValue, otherwise: HTTPError.UnexpectedContentType(HTTP.MIMEType))
    }
    
    public func validateIsSuccessfulJSON() throws {
        try validate(when: isHTTP, otherwise: HTTPError.UnexpectedResponse(self))
        try validate(when: HTTP.isSuccessful, otherwise: HTTPError.UnexpectedStatusCode(HTTP.statusCode))
        try validate(when: HTTP.isJSON, otherwise: HTTPError.UnexpectedContentType(HTTP.MIMEType))
    }
    
    public func validateIsSuccessfulImage() throws {
        try validate(when: isHTTP, otherwise: HTTPError.UnexpectedResponse(self))
        try validate(when: HTTP.isSuccessful, otherwise: HTTPError.UnexpectedStatusCode(HTTP.statusCode))
        try validate(when: HTTP.isImage, otherwise: HTTPError.UnexpectedContentType(HTTP.MIMEType))
    }
}

public extension NSHTTPURLResponse {
    public subscript(field: String) -> String? {
        return allHeaderFields[field] as? String
    }
    
    public subscript(field: HTTPResponseField) -> String? {
        return self[field.rawValue]
    }
    
    public func hasHeader(field: HTTPResponseField) -> Bool {
        return hasHeader(field.rawValue)
    }
    
    public func hasHeader(field: String) -> Bool {
        return self[field] != nil
    }
    
    public var isOK : Bool {
        return isStatus(.OK)
    }
    
    public var isSuccessful : Bool {
        return matchesStatuses([HTTPStatusSuccessful])
    }
    
    public func isStatus(code: Int) -> Bool {
        return statusCode == code
    }
    
    public func isStatus(code: HTTPStatusCode) -> Bool {
        return isStatus(code.rawValue)
    }
    
    public func matchesStatuses(codes: [HTTPStatusCode]) -> Bool {
        return matchesStatuses(rawValues(codes))
    }
    
    public func matchesStatuses(invervals: [ClosedInterval<Int>]) -> Bool {
        for interval in invervals {
            if (interval.contains(statusCode)) { return true }
        }
        
        return false
    }
    
    public func matchesStatuses(codes: [Int]) -> Bool {
        for code in codes {
            if isStatus(code) { return true }
        }
        
        return false
    }
    
    public var isJSON : Bool {
        return isContentType(.ApplicationJSON)
    }

    public var isImage : Bool {
        return matchesContentTypes([.ImageJPEG, .ImageGIF, .ImagePNG])
    }

    public func isContentType(type: String) -> Bool {
        return type == (MIMEType ?? "")
    }
    
    public func isContentType(type: HTTPMediaType) -> Bool {
        return isContentType(type.rawValue)
    }
    
    public func matchesContentTypes(types: [HTTPMediaType]) -> Bool {
        return matchesContentTypes(rawValues(types))
    }
    
    public func matchesContentTypes(types: [String]) -> Bool {
        for type in types {
            if isContentType(type) { return true }
        }
        
        return false
    }
    
    public var contentType : HTTPMediaType? {
        if let rawValue = MIMEType {
            return HTTPMediaType(rawValue: rawValue)
        } else {
            return nil
        }
    }
    
    public var contentLength : Int? {
        if expectedContentLength >= 0 && expectedContentLength <= Int64(Int.max) {
            return Int(expectedContentLength)
        } else {
            return nil
        }
    }
}
