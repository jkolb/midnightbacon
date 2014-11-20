//
//  VoteDirection.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

enum VoteDirection {
    case Upvote
    case Downvote
    case None
    
    var stringValue: String {
        switch self {
        case .Upvote:
            return "1"
        case .Downvote:
            return "-1"
        case .None:
            return "0"
        }
    }
}
