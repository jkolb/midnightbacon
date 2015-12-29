//
//  OAuthAuthorizeResponse.swift
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
import FranticApparatus
import ModestProposal

public class OAuthAuthorizeResponse : CustomStringConvertible {
    let code: String
    let state: String
    
    public init(code: String, state: String) {
        self.code = code
        self.state = state
    }
    
    public var description: String {
        return "code: \(code) state: \(state)"
    }

    public class func parseFromQuery(redirectURL: NSURL, expectedState: String) throws -> OAuthAuthorizeResponse {
        if let components = NSURLComponents(URL: redirectURL, resolvingAgainstBaseURL: true) {
            if let query = components.percentEncodedQuery {
                return try parse(query, expectedState: expectedState)
            } else {
                throw OAuthError.MissingURLQuery
            }
        } else {
            throw OAuthError.MalformedURL
        }
    }
    
    public class func parseFromFragment(redirectURL: NSURL, expectedState: String) throws -> OAuthAuthorizeResponse {
        if let components = NSURLComponents(URL: redirectURL, resolvingAgainstBaseURL: true) {
            if let fragment = components.percentEncodedFragment {
                return try parse(fragment, expectedState: expectedState)
            } else {
                throw OAuthError.MissingURLFragment
            }
        } else {
            throw OAuthError.MalformedURL
        }
    }
    
    public class func parse(formEncoded: String, expectedState: String) throws -> OAuthAuthorizeResponse {
        let components = NSURLComponents()
        components.percentEncodedQuery = formEncoded
        let queryItems = components.parameters ?? [:]
        
        if queryItems.count == 0 { throw OAuthError.EmptyURLQuery }
        
        if let errorString = queryItems["error"] {
            if "access_denied" == errorString {
                throw OAuthError.AccessDenied
            } else if "unsupported_response_type" == errorString {
                throw OAuthError.UnsupportedResponseType
            } else if "invalid_scope" == errorString {
                throw OAuthError.InvalidScope
            } else if "invalid_request" == errorString {
                throw OAuthError.InvalidRequest
            } else {
                throw OAuthError.UnexpectedError(errorString)
            }
        }
        
        let state = queryItems["state"] ?? ""
        
        if expectedState != state {
            throw OAuthError.UnexpectedState(state)
        }
        
        let code = queryItems["code"] ?? ""
        
        if code == "" {
            throw OAuthError.MissingCode
        }
        
        return OAuthAuthorizeResponse(code: code, state: state)
    }
}
