//
//  AuthorizeRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/15/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

enum TokenDuration : String {
    case Temporary = "temporary"
    case Permanent = "permanent"
}

class AuthorizeRequest {
    let clientID: String // The client ID generated during app registration
    let state: String // A string of your choosing
    let redirectURI: NSURL // The redirect URI you have specified during registration
    let duration: TokenDuration // Either temporary or permanent
    let scope: [OAuthScope] // A comma separated list of scope strings
    
    init(clientID: String, state: String, redirectURI: NSURL, duration: TokenDuration, scope: [OAuthScope]) {
        self.clientID = clientID
        self.state = state
        self.redirectURI = redirectURI
        self.duration = duration
        self.scope = scope
    }
    
    func build(builder: HTTPURLBuilder) -> NSURL {
        let query = [
            "client_id": clientID,
            "response_type": "code",
            "state": state,
            "redirect_uri": redirectURI.absoluteString!,
            "duration": duration.rawValue,
            "scope": join(",", rawValues(scope))
        ]
        if let URL = builder.URL(path: "/api/v1/authorize", query: query) {
            return URL
        } else {
            fatalError("Unable to build URL")
        }
    }
}
