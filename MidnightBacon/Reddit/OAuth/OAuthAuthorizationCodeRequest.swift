//
//  OAuthAuthorizationCodeRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/17/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation
import ModestProposal
import FranticApparatus

class OAuthAuthorizationCodeRequest : APIRequest {
    let grantType: OAuthGrantType
    let authorizeResponse: OAuthAuthorizeResponse
    let redirectURI: NSURL
    
    init(authorizeResponse: OAuthAuthorizeResponse, redirectURI: NSURL) {
        self.grantType = .AuthorizationCode
        self.authorizeResponse = authorizeResponse
        self.redirectURI = redirectURI
    }
    
    typealias ResponseType = JSON
    
    func parse(response: URLResponse, mapperFactory: RedditFactory) -> Outcome<JSON, Error> {
        return redditJSONMapper(response) { (json) -> Outcome<JSON, Error> in
            return Outcome(json)
        }
    }

    func build(prototype: NSURLRequest) -> NSMutableURLRequest {
        let request = prototype.POST(
            "/api/v1/access_token",
            parameters: [
                "grant_type": grantType.rawValue,
                "code": authorizeResponse.code,
                "redirect_uri": redirectURI.absoluteString!,
            ]
        )
        request.basicAuthorization(username: "client_id", password: "")
        return request
    }
    
    var requiresModhash : Bool {
        return false
    }
    
    var scope : OAuthScope? {
        return nil
    }
}
