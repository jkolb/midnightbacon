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

public class OAuthAuthorizeResponse : Printable {
    let code: String
    let state: String
    
    public init(code: String, state: String) {
        self.code = code
        self.state = state
    }
    
    public var description: String {
        return "code: \(code) state: \(state)"
    }

    public class func parseFromQuery(redirectURL: NSURL, expectedState: String) -> Outcome<OAuthAuthorizeResponse, Error> {
        if let components = NSURLComponents(URL: redirectURL, resolvingAgainstBaseURL: true) {
            if let query = components.percentEncodedQuery {
                return parse(query, expectedState: expectedState)
            } else {
                return Outcome(OAuthMissingURLQueryError())
            }
        } else {
            return Outcome(OAuthMalformedURLError())
        }
    }
    
    public class func parseFromFragment(redirectURL: NSURL, expectedState: String) -> Outcome<OAuthAuthorizeResponse, Error> {
        if let components = NSURLComponents(URL: redirectURL, resolvingAgainstBaseURL: true) {
            if let fragment = components.percentEncodedFragment {
                return parse(fragment, expectedState: expectedState)
            } else {
                return Outcome(OAuthMissingURLFragmentError())
            }
        } else {
            return Outcome(OAuthMalformedURLError())
        }
    }
    
    public class func parse(formEncoded: String, expectedState: String) -> Outcome<OAuthAuthorizeResponse, Error> {
        let components = NSURLComponents()
        components.percentEncodedQuery = formEncoded
        let queryItems = components.parameters ?? [:]
        
        if queryItems.count == 0 { return Outcome(OAuthEmptyURLQueryError()) }
        
        if let errorString = queryItems["error"] {
            if "access_denied" == errorString {
                return Outcome(OAuthAccessDeniedError())
            } else if "unsupported_response_type" == errorString {
                return Outcome(OAuthUnsupportedResponseTypeError())
            } else if "invalid_scope" == errorString {
                return Outcome(OAuthInvalidScopeError())
            } else if "invalid_request" == errorString {
                return Outcome(OAuthInvalidRequestError())
            } else {
                return Outcome(OAuthUnexpectedErrorStringError(message: errorString))
            }
        }
        
        let state = queryItems["state"] ?? ""
        
        if expectedState != state {
            return Outcome(OAuthUnexpectedStateError(message: state))
        }
        
        let code = queryItems["code"] ?? ""
        
        if code == "" {
            return Outcome(OAuthMissingCodeError())
        }
        
        return Outcome(OAuthAuthorizeResponse(code: code, state: state))
    }
}
