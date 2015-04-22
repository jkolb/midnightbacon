//
//  OAuthAccessToken.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 1/6/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation

struct OAuthAccessToken : DebugPrintable {
    let accessToken: String // access_token
    let tokenType: String // token_type
    let expiresIn: Double // expires_in
    let scope: String // scope
    let state: String // state
    let refreshToken: String // refresh_token
    let created: NSDate
    
    static let none = OAuthAccessToken(accessToken: "", tokenType: "", expiresIn: 0.0, scope: "", state: "", refreshToken: "", created: NSDate())
    
    var isValid: Bool {
        return !accessToken.isEmpty && !tokenType.isEmpty
    }
 
    var expires: NSDate {
        return created.dateByAddingTimeInterval(expiresIn)
    }
    
    var isExpired: Bool {
        return expires.compare(NSDate()) != .OrderedDescending
    }
    
    var authorization: String {
        return "\(tokenType) \(accessToken)"
    }
    
    var debugDescription: String {
        return "accessToken: \(accessToken) tokenType: \(tokenType) expiresIn: \(expiresIn) scope: \(scope) state: \(state) refreshToken: \(refreshToken) created: \(created)"
    }
}
