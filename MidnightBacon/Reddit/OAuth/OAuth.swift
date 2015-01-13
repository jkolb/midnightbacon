//
//  OAuth.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 1/13/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

class OAuth {
    let baseURL: NSURL
    let clientID: String
    let redirectURI: NSURL
    let duration: TokenDuration
    let scope: [OAuthScope]
    var state: String!
    
    init(baseURL: NSURL, clientID: String, redirectURI: NSURL, duration: TokenDuration, scope: [OAuthScope]) {
        self.baseURL = baseURL
        self.clientID = clientID
        self.redirectURI = redirectURI
        self.duration = duration
        self.scope = scope
    }
    
    func requestAccess() {
        state = NSUUID().UUIDString
        let request = AuthorizeRequest(clientID: clientID, state: state, redirectURI: redirectURI, duration: duration, scope: scope)
        let requestURL = request.buildURL(baseURL)
        UIApplication.sharedApplication().openURL(requestURL!)
    }
}
