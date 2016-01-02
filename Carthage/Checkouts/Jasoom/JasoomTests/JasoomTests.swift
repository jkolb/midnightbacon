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

import XCTest
@testable import Jasoom

class JasoomTests: XCTestCase {
    func testParseEmptyObject() {
        let string = "{}"
        
        do {
            let json = try JSON.parseString(string)
            XCTAssert(json.isObject, "Expecting an object")
        }
        catch {
            XCTAssert(false, "Unable to parse: \(string)")
        }
    }
    
    func testParseEmptyArray() {
        let string = "[]"
        
        do {
            let json = try JSON.parseString(string)
            XCTAssert(json.isArray, "Expecting an array")
        }
        catch {
            XCTAssert(false, "Unable to parse: \(string)")
        }
    }
    
    func testParseNull() {
        let string = "null"
        
        do {
            let json = try JSON.parseString(string, options: [.AllowFragments])
            XCTAssert(json.isNull, "Expecting null")
        }
        catch {
            XCTAssert(false, "Unable to parse: \(string)")
        }
    }
    
    func testParseTrue() {
        let string = "true"
        
        do {
            let json = try JSON.parseString(string, options: [.AllowFragments])
            XCTAssert(json.isNumber, "Expecting number")
        }
        catch {
            XCTAssert(false, "Unable to parse: \(string)")
        }
    }
    
    func testParseFalse() {
        let string = "false"
        
        do {
            let json = try JSON.parseString(string, options: [.AllowFragments])
            XCTAssert(json.isNumber, "Expecting number")
        }
        catch {
            XCTAssert(false, "Unable to parse: \(string)")
        }
    }
    
    func testParseInteger() {
        let string = "100"
        
        do {
            let json = try JSON.parseString(string, options: [.AllowFragments])
            XCTAssert(json.isNumber, "Expecting number")
        }
        catch {
            XCTAssert(false, "Unable to parse: \(string)")
        }
    }
    
    func testParseFloatingPoint() {
        let string = "100.12"
        
        do {
            let json = try JSON.parseString(string, options: [.AllowFragments])
            XCTAssert(json.isNumber, "Expecting number")
        }
        catch {
            XCTAssert(false, "Unable to parse: \(string)")
        }
    }
    
    func testParseBasicObject() {
        let string = "{\"a\":\"string\",\"b\":100.12,\"c\":true,\"d\":[],\"e\":{}}"
        
        do {
            let json = try JSON.parseString(string)
            XCTAssert(json["a"].isString, "Expecting a string")
            XCTAssert(json["b"].isNumber, "Expecting a number")
            XCTAssert(json["c"].isNumber, "Expecting a number")
            XCTAssert(json["d"].isArray, "Expecting an array")
            XCTAssert(json["e"].isObject, "Expecting an object")
            
            XCTAssertEqual(json["a"].stringValue, "string")
            XCTAssertEqual(json["b"].doubleValue, 100.12)
            XCTAssertEqual(json["c"].boolValue, true)
            XCTAssertEqual(json["d"].arrayValue, NSArray())
            XCTAssertEqual(json["e"].objectValue, NSDictionary())
        }
        catch {
            XCTAssert(false, "Unable to parse: \(string)")
        }
    }
    
    func testParseComplexObject() {
        let string = "{\"a\":{\"a1\":1},\"b\":[1]}"
        
        do {
            let json = try JSON.parseString(string)
            XCTAssert(json["a"]["a1"].isNumber, "Expecting a number")
            XCTAssert(json["b"][0].isNumber, "Expecting a number")
            
            XCTAssertEqual(json["a"]["a1"].intValue, 1)
            XCTAssertEqual(json["b"][0].intValue, 1)
        }
        catch {
            XCTAssert(false, "Unable to parse: \(string)")
        }
    }
    
    func testMissingNameAndIndex() {
        let string = "{\"a\":{\"a1\":1},\"b\":[1]}"
        
        do {
            let json = try JSON.parseString(string)
            XCTAssert(json["c"].isUndefined, "Expecting undefined")
            XCTAssert(json["z"].isUndefined, "Expecting undefined")
            XCTAssert(json["c"]["z"].isUndefined, "Expecting undefined")
            XCTAssert(json["z"][10].isUndefined, "Expecting undefined")
            
            XCTAssertEqual(json["c"].undefinedValue ?? [], ["c"])
            XCTAssertEqual(json["z"].undefinedValue ?? [], ["z"])
            XCTAssertEqual(json["c"]["z"].undefinedValue ?? [], ["c", "z"])
            XCTAssertEqual(json["z"][10].undefinedValue ?? [], ["z", "10"])
        }
        catch {
            XCTAssert(false, "Unable to parse: \(string)")
        }
    }
    
    func testCreateObject() {
        var object = JSON.objectWithCapacity(5)
        object["a"] = .String("test")
        object["b"] = .Number(100)
        object["c"] = JSON.object()
        object["c"]["c0"] = .Number(true)
        object["d"] = JSON.array()
        object["d"][0] = .String("test")
        object["d"].append(.Number(1))
        object["e"] = .Object(["e0": false])
        
        XCTAssertEqual(object["a"].stringValue, "test")
        XCTAssertEqual(object["b"].intValue, 100)
        XCTAssertTrue(object["c"].isObject)
        XCTAssertEqual(object["c"]["c0"].boolValue, true)
        XCTAssertTrue(object["d"].isArray)
        XCTAssertEqual(object["d"][0].stringValue, "test")
        XCTAssertEqual(object["d"][1].intValue, 1)
        XCTAssertEqual(object["e"]["e0"].boolValue, false)
    }
    
    func testCreateArrayWithElements() {
        var array = JSON.arrayWithElements(["test", 100, false])
        
        XCTAssertEqual(array[0].stringValue, "test")
        XCTAssertEqual(array[1].intValue, 100)
        XCTAssertEqual(array[2].boolValue, false)
    }
    
    func testCreateObjectWithNameValues() {
        var object = JSON.objectWithNameValues(["a": "test", "b": 100, "c": false])
        
        XCTAssertEqual(object["a"].stringValue, "test")
        XCTAssertEqual(object["b"].intValue, 100)
        XCTAssertEqual(object["c"].boolValue, false)
    }
    
    func testGenerateString() {
        let object = JSON.objectWithNameValues(["a": "test", "b": 100, "c": false])
        
        do {
            let string = try object.generateString()
            XCTAssertEqual(string, "{\"a\":\"test\",\"b\":100,\"c\":false}")
        }
        catch {
            XCTAssert(false, "Unable to generate string: \(object)")
        }
    }
}
