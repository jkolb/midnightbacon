//
//  OAuthRevokeTokenRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 1/7/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation
import ModestProposal
import FranticApparatus

class OAuthRevokeTokenRequest : APIRequest {
    let prototype: NSURLRequest
    let grantType: OAuthGrantType
    let accessToken: String
    
    init(prototype: NSURLRequest, accessToken: String) {
        self.prototype = prototype
        self.grantType = .RefreshToken
        self.accessToken = accessToken
    }
    
    typealias ResponseType = JSON
    
    func parse(response: URLResponse) -> Outcome<JSON, Error> {
        return redditJSONMapper(response) { (json) -> Outcome<JSON, Error> in
            return Outcome(json)
        }
    }
    
    func build() -> NSMutableURLRequest {
        let request = prototype.POST(
            "/api/v1/revoke_token",
            parameters: [
                "grant_type": grantType.rawValue,
                "refresh_token": accessToken,
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
