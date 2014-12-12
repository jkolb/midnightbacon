//
//  Thing.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/11/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

class Thing : Equatable, Hashable {
    let kind: Kind
    let id: String
    let name: String
    
    init(kind: Kind, id: String, name: String) {
        self.kind = kind
        self.id = id
        self.name = name
    }
    
    var hashValue: Int {
        return kind.hashValue ^ id.hashValue
    }
}

func ==(lhs: Thing, rhs: Thing) -> Bool {
    return lhs.kind == rhs.kind && lhs.id == rhs.id
}
