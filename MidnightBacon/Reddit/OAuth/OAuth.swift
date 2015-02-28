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
    var delegate: OAuthDelegate!
    let baseURL = NSURL(string: "https://www.reddit.com/")!
    
    func requestAccess(request: AuthorizeRequest) {
        let requestURL = request.buildURL(baseURL)
        delegate.oauthRequestAccess(self, url: requestURL!)
    }
}
