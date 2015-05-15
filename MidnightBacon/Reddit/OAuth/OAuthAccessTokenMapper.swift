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

import ModestProposal
import FranticApparatus

public class OAuthAccessTokenMapper {
    public init() { }
    
    public func map(json: JSON) -> Outcome<OAuthAccessToken, Error> {
        return Outcome(
            OAuthAccessToken(
                accessToken: json["access_token"].asString ?? "",
                tokenType: json["token_type"].asString ?? "",
                expiresIn: json["expires_in"].asDouble ?? 0.0,
                scope: json["scope"].asString ?? "",
                state: json["state"].asString ?? "",
                refreshToken: json["refresh_token"].asString ?? "",
                created: json["created"].asSecondsSince1970 ?? NSDate()
            )
        )
    }
    
    public func map(accessToken: OAuthAccessToken) -> NSData {
        let json = JSON.object()
        json["access_token"] = accessToken.accessToken.json
        json["token_type"] = accessToken.tokenType.json
        json["expires_in"] = accessToken.expiresIn.json
        json["scope"] = accessToken.scope.json
        json["state"] = accessToken.state.json
        json["refresh_token"] = accessToken.refreshToken.json
        json["created"] = accessToken.created.timeIntervalSince1970.json
        return json.format()
    }
}
