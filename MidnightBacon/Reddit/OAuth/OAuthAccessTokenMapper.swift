//
//  OAuthAccessTokenMapper.swift
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

import Jasoom

public class OAuthAccessTokenMapper {
    public init() { }
    
    public func map(json: JSON) throws -> OAuthAccessToken {
        return OAuthAccessToken(
            accessToken: json["access_token"].textValue ?? "",
            tokenType: json["token_type"].textValue ?? "",
            expiresIn: json["expires_in"].doubleValue ?? 0.0,
            scope: json["scope"].textValue ?? "",
            state: json["state"].textValue ?? "",
            refreshToken: json["refresh_token"].textValue ?? "",
            created: json["created"].dateValue ?? NSDate()
        )

    }
    
    public func map(accessToken: OAuthAccessToken) throws -> NSData {
        var json = JSON.object()
        json["access_token"] = .String(accessToken.accessToken)
        json["token_type"] = .String(accessToken.tokenType)
        json["expires_in"] = .Number(accessToken.expiresIn)
        json["scope"] = .String(accessToken.scope)
        json["state"] = .String(accessToken.state)
        json["refresh_token"] = .String(accessToken.refreshToken)
        json["created"] = .Number(accessToken.created.timeIntervalSince1970)
        return try json.generateData()
    }
}
