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

public enum JSON {
    case Array(NSArray)
    case Number(NSNumber)
    case Object(NSDictionary)
    case String(NSString)
    case Null
    case Undefined([Name])
    
    public typealias Name = Swift.String
    
    public static func parseString(string: NSString, options: NSJSONReadingOptions = []) throws -> JSON {
        return try parseData(string.dataUsingEncoding(NSUTF8StringEncoding)!, options: options)
    }
    
    public static func parseData(data: NSData, options: NSJSONReadingOptions = []) throws -> JSON {
        return wrap(try NSJSONSerialization.JSONObjectWithData(data, options: options))
    }
    
    public func generateString(options options: NSJSONWritingOptions = []) throws -> NSString {
        return Swift.String(data: try generateData(options: options), encoding: NSUTF8StringEncoding)!
    }
    
    public func generateData(options options: NSJSONWritingOptions = []) throws -> NSData {
        return try NSJSONSerialization.dataWithJSONObject(unwrap(), options: options)
    }
    
    public static func object() -> JSON {
        return .Object(NSMutableDictionary())
    }
    
    public static func objectWithCapacity(capacity: Int) -> JSON {
        return .Object(NSMutableDictionary(capacity: capacity))
    }
    
    public static func objectWithNameValues(nameValues: NSDictionary) -> JSON {
        return .Object(NSMutableDictionary(dictionary: nameValues))
    }
    
    public static func array() -> JSON {
        return .Array(NSMutableArray())
    }
    
    public static func arrayWithCapacity(capacity: Int) -> JSON {
        return .Array(NSMutableArray(capacity: capacity))
    }
    
    public static func arrayWithElements(elements: NSArray) -> JSON {
        return .Array(NSMutableArray(array: elements))
    }
    
    private static func wrap(object: AnyObject) -> JSON {
        switch object {
        case let convertible as JSONConvertible:
            return convertible.convertToJSON()
        default:
            fatalError("\(object) not JSONConvertible")
        }
    }
    
    private func unwrap() -> AnyObject {
        switch self {
        case let .Array(array):
            return array
        case let .Object(object):
            return object
        case let .Number(number):
            return number
        case let .String(string):
            return string
        case let .Undefined(names):
            return names
        case .Null:
            return NSNull()
        }
    }
    
    public var count: Int {
        switch self {
        case let .Object(object):
            return object.count
        case let .Array(array):
            return array.count
        default:
            return 0
        }
    }
    
    public subscript(name: Name) -> JSON {
        get {
            switch self {
            case let .Object(object):
                if let value = object[name] {
                    return JSON.wrap(value)
                }
                else {
                    return .Undefined([name])
                }
            case let .Undefined(names):
                return .Undefined(names + [name])
            default:
                return .Undefined([name])
            }
        }
        set {
            switch self {
            case let .Object(object):
                switch object {
                case let mutableObject as NSMutableDictionary:
                    mutableObject[name] = newValue.unwrap()
                default:
                    fatalError("JSON object is not mutable")
                }
            default:
                fatalError("Value is not a JSON object")
            }
        }
    }
    
    public subscript(index: Int) -> JSON {
        get {
            switch self {
            case let .Array(array):
                if index < array.count {
                    return JSON.wrap(array[index])
                }
                else {
                    return .Undefined(["\(index)"])
                }
            case let .Undefined(names):
                return .Undefined(names + ["\(index)"])
            default:
                return .Undefined(["\(index)"])
            }
        }
        set {
            switch self {
            case let .Array(array):
                switch array {
                case let mutableArray as NSMutableArray:
                    mutableArray[index] = newValue.unwrap()
                default:
                    fatalError("JSON array is not mutable")
                }
            default:
                fatalError("Value is not a JSON array")
            }
        }
    }
    
    public func append(value: JSON) {
        switch self {
        case let .Array(array):
            switch array {
            case let mutableArray as NSMutableArray:
                mutableArray.addObject(value.unwrap())
            default:
                fatalError("JSON array is not mutable")
            }
        default:
            fatalError("Value is not a JSON array")
        }
    }
    
    public func removeIndex(index: Int) {
        switch self {
        case let .Array(array):
            switch array {
            case let mutableArray as NSMutableArray:
                mutableArray.removeObjectAtIndex(index)
            default:
                fatalError("JSON array is not mutable")
            }
        default:
            fatalError("Value is not a JSON array")
        }
    }
    
    public func removeName(name: Name) {
        switch self {
        case let .Object(object):
            switch object {
            case let mutableObject as NSMutableDictionary:
                mutableObject.removeObjectForKey(name)
            default:
                fatalError("JSON object is not mutable")
            }
        default:
            fatalError("Value is not a JSON object")
        }
    }
    
    public var isNull: Bool {
        switch self {
        case .Null:
            return true
        default:
            return false
        }
    }
    
    public var isUndefined: Bool {
        switch self {
        case .Undefined:
            return true
        default:
            return false
        }
    }
    
    public var isObject: Bool {
        switch self {
        case .Object:
            return true
        default:
            return false
        }
    }
    
    public var isArray: Bool {
        switch self {
        case .Array:
            return true
        default:
            return false
        }
    }
    
    public var isString: Bool {
        switch self {
        case .String:
            return true
        default:
            return false
        }
    }
    
    public var isNumber: Bool {
        switch self {
        case .Number:
            return true
        default:
            return false
        }
    }
    
    public var isMutable: Bool {
        switch self {
        case let .Array(array):
            switch array {
            case is NSMutableArray:
                return true
            default:
                return false
            }
        case let .Object(object):
            switch object {
            case is NSMutableDictionary:
                return true
            default:
                return false
            }
        default:
            return false
        }
    }
    
    public var doubleValue: Double? {
        if let value = numberValue {
            return value.doubleValue
        }
        else {
            return nil
        }
    }
    
    public var intValue: Int? {
        if let value = numberValue {
            return value.integerValue
        }
        else {
            return nil
        }
    }
    
    public var boolValue: Bool? {
        if let value = numberValue {
            return value.boolValue
        }
        else {
            return nil
        }
    }
    
    public var numberValue: NSNumber? {
        switch self {
        case let .Number(number):
            return number
        default:
            return nil
        }
    }
    
    public var stringValue: NSString? {
        switch self {
        case let .String(string):
            return string
        default:
            return nil
        }
    }
    
    public var arrayValue: NSArray? {
        switch self {
        case let .Array(array):
            return array
        default:
            return nil
        }
    }
    
    public var objectValue: NSDictionary? {
        switch self {
        case let .Object(object):
            return object
        default:
            return nil
        }
    }
    
    public var nullValue: NSNull? {
        switch self {
        case .Null:
            return NSNull()
        default:
            return nil
        }
    }
    
    public var undefinedValue: [Name]? {
        switch self {
        case let .Undefined(names):
            return names
        default:
            return nil
        }
    }
}

extension JSON : CustomStringConvertible {
    public var description: Swift.String {
        do {
            return try generateString(options: [.PrettyPrinted]) as Swift.String
        }
        catch {
            return "Unable to generate description: \(self)"
        }
    }
}

private protocol JSONConvertible {
    func convertToJSON() -> JSON
}

extension NSDictionary : JSONConvertible {
    public func convertToJSON() -> JSON {
        return .Object(self)
    }
}

extension NSArray : JSONConvertible {
    public func convertToJSON() -> JSON {
        return .Array(self)
    }
}

extension NSNumber : JSONConvertible {
    public func convertToJSON() -> JSON {
        return .Number(self)
    }
}

extension NSString : JSONConvertible {
    public func convertToJSON() -> JSON {
        return .String(self)
    }
}

extension NSNull : JSONConvertible {
    public func convertToJSON() -> JSON {
        return .Null
    }
}
