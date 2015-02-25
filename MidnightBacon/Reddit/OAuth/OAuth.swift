//
//  OAuth.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 1/13/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

protocol OAuthDelegate {
    func oauthRequestAccess(oauth: OAuth, url: NSURL)
}

class OAuth {
    let baseURL: NSURL
    let clientID: String
    let redirectURI: NSURL
    let duration: TokenDuration
    let scope: [OAuthScope]
    var state: String!
    var delegate: OAuthDelegate!
    
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
        delegate.oauthRequestAccess(self, url: requestURL!)
    }
}
