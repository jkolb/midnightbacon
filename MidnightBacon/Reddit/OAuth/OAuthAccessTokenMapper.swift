//
//  OAuthAccessTokenMapper.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/18/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import ModestProposal
import FranticApparatus

class OAuthAccessTokenMapper {
    func map(json: JSON) -> Outcome<OAuthAccessToken, Error> {
        return Outcome(
            OAuthAccessToken(
                accessToken: json["access_token"].asString ?? "",
                tokenType: json["token_type"].asString ?? "",
                expiresIn: json["expires_in"].asDouble ?? 0.0,
                scope: json["scope"].asString ?? "",
                state: json["state"].asString ?? "",
                refreshToken: json["refresh_token"].asString ?? "",
                created: json["created"].asSecondsSince1970 ?? NSDate()
            )
        )
    }
    
    func map(accessToken: OAuthAccessToken) -> NSData {
        let json = JSON.object()
        json["access_token"] = accessToken.accessToken.json
        json["token_type"] = accessToken.tokenType.json
        json["expires_in"] = accessToken.expiresIn.json
        json["scope"] = accessToken.scope.json
        json["state"] = accessToken.state.json
        json["refresh_token"] = accessToken.refreshToken.json
        json["created"] = accessToken.created.timeIntervalSince1970.json
        return json.format()
    }
}
