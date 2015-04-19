//
//  OAuthAccessToken.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 1/6/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

struct OAuthAccessToken : DebugPrintable {
    let accessToken: String // access_token
    let tokenType: String // token_type
    let expiresIn: String // expires_in
    let scope: String // scope
    let state: String // state
    let refreshToken: String // refresh_token
    
    static let none = OAuthAccessToken(accessToken: "", tokenType: "", expiresIn: "", scope: "", state: "", refreshToken: "")
    
    var isValid: Bool {
        return !accessToken.isEmpty && !tokenType.isEmpty
    }
 
    var isExpired: Bool {
        return false
    }
    
    var authorization: String {
        return "\(tokenType) \(accessToken)"
    }
    
    var debugDescription: String {
        return "accessToken: \(accessToken) tokenType: \(tokenType) expiresIn: \(expiresIn) scope: \(scope) state: \(state) refreshToken: \(refreshToken)"
    }
}
