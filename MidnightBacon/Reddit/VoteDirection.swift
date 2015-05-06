//
//  VoteDirection.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

public enum VoteDirection : Int {
    case Upvote = 1
    case Downvote = -1
    case None = 0
    
    public var stringValue: String {
        return String(rawValue)
    }
}
