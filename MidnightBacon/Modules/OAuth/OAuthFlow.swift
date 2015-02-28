//
//  OAuthFlow.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 2/25/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation

class OAuthFlow : NSObject, OAuthDelegate, WebViewControllerDelegate {
    var oauth: OAuth!
    var presenter: Presenter!
    var oauthFactory: OAuthFactory!

    let clientID = "fnOncggIlO7nwA"
    let redirectURI = NSURL(string: "midnightbacon://oauth_redirect")!
    let duration = TokenDuration.Permanent
    let scope: [OAuthScope] = [.Read, .PrivateMessages, .Vote]

    func present() {
        let request = AuthorizeRequest(clientID: clientID, state: NSUUID().UUIDString, redirectURI: redirectURI, duration: duration, scope: scope)
        oauth.requestAccess(request)
    }
    
    func cancel() {
        presenter.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func oauthRequestAccess(oauth: OAuth, url: NSURL) {
        let viewController = oauthFactory.oauthNavigationViewController(url)
        presenter.presentViewController(viewController, animated: true, completion: nil)
    }
    
    func webViewController(viewController: WebViewController, handleApplicationURL URL: NSURL) {
        println("Redirected successfully \(URL)")
    }
}
