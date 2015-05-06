//
//  Listing.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

public class Listing {
    let children: [Thing]
    let after: String
    let before: String
    let modhash: String
    
    public class func empty() -> Listing {
        return Listing(children: [], after: "", before: "", modhash: "")
    }
    
    public init (children: [Thing], after: String, before: String, modhash: String) {
        self.children = children
        self.after = after
        self.before = before
        self.modhash = modhash
    }
    
    public var count: Int {
        return children.count
    }
    
    public subscript(index: Int) -> Thing {
        return children[index]
    }
}
