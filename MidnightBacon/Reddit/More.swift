//
//  More.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 3/19/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

class More : Thing {
    let parentID: String
    let count: Int
    let children: [String]
    var depth = 0
    
    init(id: String, name: String, parentID: String, count: Int, children: [String]) {
        self.parentID = parentID
        self.count = count
        self.children = children
        super.init(kind: .More, id: id, name: name)
    }
}
