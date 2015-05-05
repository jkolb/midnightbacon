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
    let mapperFactory: RedditFactory
    let grantType: OAuthGrantType
    let clientID: String
    let authorizeResponse: OAuthAuthorizeResponse
    let redirectURI: NSURL
    
    init(mapperFactory: RedditFactory, clientID: String, authorizeResponse: OAuthAuthorizeResponse, redirectURI: NSURL) {
        self.mapperFactory = mapperFactory
        self.grantType = .AuthorizationCode
        self.clientID = clientID
        self.authorizeResponse = authorizeResponse
        self.redirectURI = redirectURI
    }
    
    typealias ResponseType = OAuthAccessToken
    
    func parse(response: URLResponse) -> Outcome<OAuthAccessToken, Error> {
        let mapperFactory = self.mapperFactory
        return redditJSONMapper(response) { (json) -> Outcome<OAuthAccessToken, Error> in
            return mapperFactory.accessTokenMapper().map(json)
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
