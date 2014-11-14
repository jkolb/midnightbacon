//
//  SessionMapperTests.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/13/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import XCTest

class SessionMapperTests: XCTestCase {
    func testExample() {
        let session = Session(modhash: "A", cookie: "B", needHTTPS: true)
        let expected = Session(modhash: "A", cookie: "B", needHTTPS: true)
        let mapper = SessionMapper()
        
        XCTAssertEqual(expected, mapper.fromData(mapper.toData(session)), "Mapping failed")
    }
}
