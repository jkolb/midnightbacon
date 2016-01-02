//
//  AuthorizeRequest.swift
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
import ModestProposal

public enum TokenDuration : String {
    case Temporary = "temporary"
    case Permanent = "permanent"
}

public class AuthorizeRequest {
    let clientID: String // The client ID generated during app registration
    let state: String // A string of your choosing
    let redirectURI: NSURL // The redirect URI you have specified during registration
    let duration: TokenDuration // Either temporary or permanent
    let scope: [OAuthScope] // A comma separated list of scope strings
    
    public init(clientID: String, state: String, redirectURI: NSURL, duration: TokenDuration, scope: [OAuthScope]) {
        self.clientID = clientID
        self.state = state
        self.redirectURI = redirectURI
        self.duration = duration
        self.scope = scope
    }
    
    public func buildURL(prototype: NSURL) -> NSURL? {
        return prototype.relativeToPath(
            "/api/v1/authorize.compact",
            parameters: [
                "client_id": clientID,
                "response_type": "code",
                "state": state,
                "redirect_uri": redirectURI.absoluteString,
                "duration": duration.rawValue,
                "scope": rawValues(scope).joinWithSeparator(","),
            ]
        )
    }
}
