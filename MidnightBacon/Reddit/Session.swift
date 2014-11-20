//
//  RedditSession.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

struct Session: Equatable {
    let modhash: String
    let cookie: String
    let needHTTPS: Bool
    
    static var anonymous: Session {
        return Session(modhash: "", cookie: "", needHTTPS: false)
    }
}

func ==(lhs: Session, rhs: Session) -> Bool {
    return lhs.modhash == rhs.modhash && lhs.cookie == rhs.cookie && lhs.needHTTPS == rhs.needHTTPS
}
