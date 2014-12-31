//
//  OAuthAuthorizeResponse.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/16/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation
import FranticApparatus
import ModestProposal

class OAuthAuthorizeResponse {
    let code: String
    let state: String
    
    init(code: String, state: String) {
        self.code = code
        self.state = state
    }
    
    class func create(redirectURL: NSURL, expectedState: String) -> Outcome<OAuthAuthorizeResponse, Error> {
        if let components = NSURLComponents(URL: redirectURL, resolvingAgainstBaseURL: true) {
            let queryItems = components.parameters ?? [:]
            
            if queryItems.count == 0 { return .Failure(OAuthEmptyURLQueryError()) }
            
            if let errorString = queryItems["error"] {
                if "access_denied" == errorString {
                    return .Failure(OAuthAccessDeniedError())
                } else if "unsupported_response_type" == errorString {
                    return .Failure(OAuthUnsupportedResponseTypeError())
                } else if "invalid_scope" == errorString {
                    return .Failure(OAuthInvalidScopeError())
                } else if "invalid_request" == errorString {
                    return .Failure(OAuthInvalidRequestError())
                } else {
                    return .Failure(OAuthUnexpectedErrorStringError(message: errorString))
                }
            }

            let state = queryItems["state"] ?? ""
            
            if expectedState != state {
                return .Failure(OAuthUnexpectedStateError(message: state))
            }
            
            let code = queryItems["code"] ?? ""
            
            if code == "" {
                return .Failure(OAuthMissingCodeError())
            }
            
            return .Success(OAuthAuthorizeResponse(code: code, state: state))
        } else {
            return .Failure(OAuthMalformedURLError())
        }
    }
}
