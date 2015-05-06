//
//  OAuthAccessToken.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 1/6/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation
import Common

public struct OAuthAccessToken : AuthorizationToken, DebugPrintable {
    let accessToken: String // access_token
    let tokenType: String // token_type
    let expiresIn: Double // expires_in
    let scope: String // scope
    let state: String // state
    let refreshToken: String // refresh_token
    let created: NSDate
    
    public static let none = OAuthAccessToken(accessToken: "", tokenType: "", expiresIn: 0.0, scope: "", state: "", refreshToken: "", created: NSDate())
    
    public var isValid: Bool {
        return !accessToken.isEmpty && !tokenType.isEmpty
    }
 
    public var expires: NSDate {
        return created.dateByAddingTimeInterval(expiresIn)
    }
    
    public var isExpired: Bool {
        return expires.compare(NSDate()) != .OrderedDescending
    }
    
    public var authorization: String {
        return "\(tokenType) \(accessToken)"
    }
    
    public var debugDescription: String {
        return "accessToken: \(accessToken) tokenType: \(tokenType) expiresIn: \(expiresIn) scope: \(scope) state: \(state) refreshToken: \(refreshToken) created: \(created)"
    }
}
