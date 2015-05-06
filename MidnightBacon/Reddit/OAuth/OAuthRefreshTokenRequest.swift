//
//  OAuthRefreshTokenRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 1/7/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation
import ModestProposal
import FranticApparatus
import Common

class OAuthRefreshTokenRequest : APIRequest {
    let mapperFactory: RedditFactory
    let prototype: NSURLRequest
    let grantType: OAuthGrantType
    let clientID: String
    let accessToken: OAuthAccessToken

    init(mapperFactory: RedditFactory, prototype: NSURLRequest, clientID: String, accessToken: OAuthAccessToken) {
        self.mapperFactory = mapperFactory
        self.prototype = prototype
        self.grantType = .RefreshToken
        self.clientID = clientID
        self.accessToken = accessToken
    }
    
    typealias ResponseType = OAuthAccessToken
    
    func parse(response: URLResponse) -> Outcome<OAuthAccessToken, Error> {
        let mapperFactory = self.mapperFactory
        return redditJSONMapper(response) { (json) -> Outcome<OAuthAccessToken, Error> in
            return mapperFactory.accessTokenMapper().map(json)
        }
    }
    
    func build() -> NSMutableURLRequest {
        let request = prototype.POST(
            "/api/v1/access_token",
            parameters: [
                "grant_type": grantType.rawValue,
                "refresh_token": accessToken.refreshToken,
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
