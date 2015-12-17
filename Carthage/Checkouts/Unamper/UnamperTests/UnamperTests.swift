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
@testable import Unamper

class UnamperTests: XCTestCase {
    func assertUnescaped(escaped escaped: String, unescaped: String) {
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
        assertUnescaped(escaped: "&quot;Peas &amp; Carrots&quot;", unescaped: "\"Peas & Carrots\"")
    }
}
