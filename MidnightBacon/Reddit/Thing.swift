//
//  Thing.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/11/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

public class Thing : Equatable, Hashable, DebugPrintable {
    let kind: Kind
    let id: String
    let name: String
    
    public init(kind: Kind, id: String, name: String) {
        self.kind = kind
        self.id = id
        self.name = name
    }
    
    public var hashValue: Int {
        return kind.hashValue ^ id.hashValue
    }
    
    public var debugDescription: String {
        return "\(kind.rawValue) \(id)"
    }
}

public func ==(lhs: Thing, rhs: Thing) -> Bool {
    return lhs.kind == rhs.kind && lhs.id == rhs.id
}
