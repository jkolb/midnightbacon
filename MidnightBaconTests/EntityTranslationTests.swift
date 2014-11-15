//
//  EntityTranslationTests.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/15/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import XCTest

class EntityTranslationTests: XCTestCase {
    func assertUnescaped(# escaped: String, unescaped: String) {
        XCTAssertEqual(unescaped, escaped.unescapeEntities(), "Failed")
    }
    
    func testCanUnescape() {
        assertUnescaped(escaped: "", unescaped: "")
        assertUnescaped(escaped: "a", unescaped: "a")
        assertUnescaped(escaped: "&", unescaped: "&")
        assertUnescaped(escaped: "&&", unescaped: "&&")
        assertUnescaped(escaped: "&&;", unescaped: "&&;")
        assertUnescaped(escaped: "&&;&", unescaped: "&&;&")
        assertUnescaped(escaped: "&a&a;&a", unescaped: "&a&a;&a")
        assertUnescaped(escaped: "&lt", unescaped: "&lt")
        assertUnescaped(escaped: "&abcde;", unescaped: "&abcde;")
        assertUnescaped(escaped: "&quot;", unescaped: "\"")
        assertUnescaped(escaped: "&amp;", unescaped: "&")
        assertUnescaped(escaped: "&lt;", unescaped: "<")
        assertUnescaped(escaped: "&gt;", unescaped: ">")
        assertUnescaped(escaped: "&apos;", unescaped: "'")
        assertUnescaped(escaped: "a&lt;", unescaped: "a<")
        assertUnescaped(escaped: "&abcd&e;", unescaped: "&abcd&e;")
        assertUnescaped(escaped: "&abcd&apos;", unescaped: "&abcd'")
        assertUnescaped(escaped: "&abcdefghijklmnop;", unescaped: "&abcdefghijklmnop;")
    }
}
