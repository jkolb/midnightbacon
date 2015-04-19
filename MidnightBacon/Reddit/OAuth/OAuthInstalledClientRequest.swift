//
//  OAuthInstalledClientRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/18/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation
import ModestProposal
import FranticApparatus

class OAuthInstalledClientRequest : APIRequest {
    let grantType: OAuthGrantType
    let clientID: String
    let deviceID: NSUUID
    
    init(clientID: String, deviceID: NSUUID) {
        self.grantType = .InstalledClient
        self.clientID = clientID
        self.deviceID = deviceID
    }
    
    typealias ResponseType = OAuthAccessToken
    
    func parse(response: URLResponse, mapperFactory: RedditFactory) -> Outcome<OAuthAccessToken, Error> {
        return redditJSONMapper(response) { (json) -> Outcome<OAuthAccessToken, Error> in
            return mapperFactory.accessTokenMapper().map(json)
        }
    }
    
    func build(prototype: NSURLRequest) -> NSMutableURLRequest {
        let request = prototype.POST(
            "/api/v1/access_token",
            parameters: [
                "grant_type": grantType.rawValue,
                "device_id": deviceID.UUIDString,
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
