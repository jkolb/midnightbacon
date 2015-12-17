//
//  ModestProposalTests.swift
//  ModestProposalTests
//
//  Created by Justin Kolb on 12/17/15.
//  Copyright © 2015 Justin Kolb. All rights reserved.
//

import XCTest
@testable import ModestProposal

class ModestProposalTests: XCTestCase {
    func testBuildPaths() {
        assert(baseURL: "http://test.com", path: "", parameters: [:], equals: "http://test.com")
        assert(baseURL: "http://test.com", path: "test", parameters: [:], equals: "http://test.com/test")
        assert(baseURL: "http://test.com", path: "/test", parameters: [:], equals: "http://test.com/test")
        assert(baseURL: "http://test.com", path: "test/", parameters: [:], equals: "http://test.com/test/")
        assert(baseURL: "http://test.com", path: "/test/", parameters: [:], equals: "http://test.com/test/")
        
        assert(baseURL: "http://test.com/", path: "", parameters: [:], equals: "http://test.com/")
        assert(baseURL: "http://test.com/", path: "test", parameters: [:], equals: "http://test.com/test")
        assert(baseURL: "http://test.com/", path: "/test", parameters: [:], equals: "http://test.com/test")
        assert(baseURL: "http://test.com/", path: "test/", parameters: [:], equals: "http://test.com/test/")
        assert(baseURL: "http://test.com/", path: "/test/", parameters: [:], equals: "http://test.com/test/")
        
        assert(baseURL: "http://test.com/test", path: "", parameters: [:], equals: "http://test.com/test")
        assert(baseURL: "http://test.com/test", path: "A", parameters: [:], equals: "http://test.com/A")
        assert(baseURL: "http://test.com/test", path: "A/", parameters: [:], equals: "http://test.com/A/")
        assert(baseURL: "http://test.com/test", path: "/A", parameters: [:], equals: "http://test.com/A")
        assert(baseURL: "http://test.com/test", path: "/A/", parameters: [:], equals: "http://test.com/A/")
        
        assert(baseURL: "http://test.com/test/", path: "", parameters: [:], equals: "http://test.com/test/")
        assert(baseURL: "http://test.com/test/", path: "A", parameters: [:], equals: "http://test.com/test/A")
        assert(baseURL: "http://test.com/test/", path: "A/", parameters: [:], equals: "http://test.com/test/A/")
        assert(baseURL: "http://test.com/test/", path: "A", parameters: [:], equals: "http://test.com/test/A")
        assert(baseURL: "http://test.com/test/", path: "A/", parameters: [:], equals: "http://test.com/test/A/")
        
        assert(baseURL: "http://test.com/test%20A/", path: "", parameters: [:], equals: "http://test.com/test%20A/")
        assert(baseURL: "http://test.com/test%20A/", path: "A", parameters: [:], equals: "http://test.com/test%20A/A")
        assert(baseURL: "http://test.com/test%20A/", path: "A/", parameters: [:], equals: "http://test.com/test%20A/A/")
        assert(baseURL: "http://test.com/test%20A/", path: "A", parameters: [:], equals: "http://test.com/test%20A/A")
        assert(baseURL: "http://test.com/test%20A/", path: "A/", parameters: [:], equals: "http://test.com/test%20A/A/")
        
        assert(baseURL: "http://test.com/test/", path: "", parameters: [:], equals: "http://test.com/test/")
        assert(baseURL: "http://test.com/test/", path: "A%20A", parameters: [:], equals: "http://test.com/test/A%20A")
        assert(baseURL: "http://test.com/test/", path: "A%20A/", parameters: [:], equals: "http://test.com/test/A%20A/")
        assert(baseURL: "http://test.com/test/", path: "A%20A", parameters: [:], equals: "http://test.com/test/A%20A")
        assert(baseURL: "http://test.com/test/", path: "A%20A/", parameters: [:], equals: "http://test.com/test/A%20A/")
    }
    
    func testBuildParameters() {
        assert(baseURL: "http://test.com", path: "", parameters: [:], equals: "http://test.com")
        assert(baseURL: "http://test.com", path: "", parameters: ["test":""], equals: "http://test.com?test=")
        assert(baseURL: "http://test.com", path: "", parameters: ["test":"A"], equals: "http://test.com?test=A")
        assert(baseURL: "http://test.com", path: "", parameters: ["test":"A A"], equals: "http://test.com?test=A%20A")
    }
    
    func testRetrieveParameters() {
        assert(URL: "http://test.com", expected: [:])
        assert(URL: "http://test.com?", expected: [:])
        assert(URL: "http://test.com?test=", expected: ["test": ""])
        assert(URL: "http://test.com?test=A", expected: ["test": "A"])
        assert(URL: "http://test.com?test=A%20A", expected: ["test": "A A"])
        assert(URL: "http://test.com?test=A", expected: ["test": "A"])
        assert(URL: "http://test.com?test=A&test=B", expected: ["test": "B"])
        assert(URL: "http://test.com?test1=A&test2=B", expected: ["test1": "A", "test2": "B"])
    }
    
    func assert(baseURL baseURL: String, path: String, parameters: [String:String], equals: String) {
        let baseURL = NSURL(string: baseURL)!
        let builtURL = baseURL.relativeToPath(path, parameters: parameters)
        XCTAssertEqual(builtURL.absoluteString, equals, "Failed")
    }
    
    func assert(URL URL: String, expected: [String:String]) {
        let baseURL = NSURL(string: URL)!
        XCTAssertEqual(baseURL.parameters, expected, "Failed")
    }
}
