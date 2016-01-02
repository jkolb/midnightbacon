//
//  OAuthAccessToken.swift
//  MidnightBacon
//
// Copyright (c) 2015 Justin Kolb - http://franticapparatus.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation
import Common

public struct OAuthAccessToken : AuthorizationToken, CustomDebugStringConvertible {
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
