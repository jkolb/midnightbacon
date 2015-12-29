//
//  ThingMapper.swift
//  MidnightBacon
//
// Copyright (c) 2015 Justin Kolb - http://franticapparatus.net
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
//

import Jasoom
import Unamper

public enum ThingError : ErrorType {
    case UnexpectedJSON
    case MissingThingData
    case NoMapperForKind(Kind)
    case UnknownKind(String)
    case ListingMissingChildren
    case InvalidLinkURL(String)
}

protocol ThingMapper {
    func map(json: JSON) throws -> Thing
}

extension JSON {
    public var dateValue: NSDate? {
        if let seconds = doubleValue {
            return NSDate(timeIntervalSince1970: seconds)
        }
        else {
            return nil
        }
    }
    
    public var kindValue: Kind? {
        return Kind(rawValue: textValue ?? "")
    }
    
    public var textValue: Swift.String? {
        return stringValue as? Swift.String
    }
    
    public var unescapedTextValue: Swift.String? {
        if let text = textValue {
            return text.unescapeEntities()
        }
        else {
            return nil
        }
    }
    
    public var textArrayValue: [Swift.String]? {
        if let array = arrayValue {
            var values: [Swift.String] = []
            
            for item in array {
                if let string = item as? NSString {
                    values.append(string as Swift.String)
                }
            }
            
            return values
        }
        else {
            return nil
        }
    }
    
    public var URLValue: NSURL? {
        if let text = textValue {
            return NSURL(string: text)
        }
        else {
            return nil
        }
    }
}
