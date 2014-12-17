//
//  OAuthAuthorizeResponse.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/16/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation
import FranticApparatus

class OAuthAuthorizeResponse {
    let code: String
    let state: String
    
    init(code: String, state: String) {
        self.code = code
        self.state = state
    }
    
    class func create(redirectURL: NSURL, expectedState: String) -> Outcome<OAuthAuthorizeResponse, Error> {
        if let components = NSURLComponents(URL: redirectURL, resolvingAgainstBaseURL: true) {
            let queryItems = dictionary(queryItems: components.queryItems as? [NSURLQueryItem])
            
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

            let state = valueOtherwise(queryItems["state"], "")
            
            if expectedState != state {
                return .Failure(OAuthUnexpectedStateError(message: state))
            }
            
            let code = valueOtherwise(queryItems["code"], "")
            
            if code == "" {
                return .Failure(OAuthMissingCodeError())
            }
            
            return .Success(OAuthAuthorizeResponse(code: code, state: state))
        } else {
            return .Failure(OAuthMalformedURLError())
        }
    }
}

func valueOtherwise<T>(valueOrNil: Optional<T>, otherwise: T) -> T {
    if let value = valueOrNil {
        return value
    } else {
        return otherwise
    }
}

func dictionary(queryItems queryItemsOrNil: [NSURLQueryItem]?) -> [String:String] {
    if let queryItems = queryItemsOrNil {
        var d = [String:String](minimumCapacity: queryItems.count)
        
        for queryItem in queryItems {
            d[queryItem.name] = queryItem.value
        }
        
        return d
    } else {
        return [String:String]()
    }
}
