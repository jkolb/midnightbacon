//
//  OAuthAccessTokenRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/17/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation
import ModestProposal
import FranticApparatus

class OAuthAccessTokenRequest : APIRequest {
    let authorizeResponse: OAuthAuthorizeResponse
    let clientID: String
    let redirectURI: NSURL
    
    init(authorizeResponse: OAuthAuthorizeResponse, clientID: String, redirectURI: NSURL) {
        self.authorizeResponse = authorizeResponse
        self.clientID = clientID
        self.redirectURI = redirectURI
    }
    
    typealias ResponseType = JSON
    
    func parse(response: URLResponse, mapperFactory: RedditFactory) -> Outcome<JSON, Error> {
        return redditJSONMapper(response) { (json) -> Outcome<JSON, Error> in
            return .Success(json)
        }
    }

    func build(prototype: NSURLRequest) -> NSMutableURLRequest {
        let request = prototype.POST(
            "/api/v1/access_token",
            parameters: [
                "grant_type": "authorization_code",
                "code": authorizeResponse.code,
                "redirect_uri": redirectURI.absoluteString!,
            ]
        )
        request.basicAuthorization(username: clientID, password: "")
        return request
    }
    
    var requiresModhash : Bool {
        return false
    }
    
    var scope : OAuthScope? {
        return nil
    }
}
