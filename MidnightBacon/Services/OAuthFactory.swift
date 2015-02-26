//
//  OAuthFactory.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 2/25/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import FieryCrucible

class OAuthFactory : DependencyFactory {
    var sharedFactory: SharedFactory!
    
    func oauthFlow() -> OAuthFlow {
        return shared(
            "oauthFlow",
            factory: OAuthFlow(),
            configure: { [unowned self] (instance) in
                instance.oauth = self.oauth()
                instance.oauthFactory = self
                instance.presenter = self.sharedFactory.presenter()
            }
        )
    }
    
    func oauth() -> OAuth {
        let baseURL = NSURL(string: "https://www.reddit.com/")!
        let clientID = "fnOncggIlO7nwA"
        let redirectURI = NSURL(string: "midnightbacon://oauth_redirect")!
        let duration = TokenDuration.Permanent
        let scope: [OAuthScope] = [.Read, .PrivateMessages, .Vote]
        return shared(
            "oauth",
            factory: OAuth(baseURL: baseURL, clientID: clientID, redirectURI: redirectURI, duration: duration, scope: scope),
            configure: { [unowned self] (instance) in
                instance.delegate = self.oauthFlow()
            }
        )
    }
    
    func oauthNavigationViewController(url: NSURL) -> UINavigationController {
        return scoped(
            "oauthNavigationViewController",
            factory: UINavigationController(rootViewController: oauthLoginViewController(url)),
            configure: { [unowned self] (instance) in
                let rootViewController = instance.viewControllers[0] as! UIViewController
                rootViewController.navigationItem.leftBarButtonItem = self.oauthCancelBarButtonItem()
            }
        )
    }
    
    func oauthLoginViewController(url: NSURL) -> WebViewController {
        return scoped(
            "oauthLoginViewController",
            factory: WebViewController(),
            configure: { [unowned self] (instance) in
                instance.style = self.sharedFactory.style()
                instance.title = "OAuth"
                instance.url = url
            }
        )
    }
    
    func oauthCancelBarButtonItem() -> UIBarButtonItem {
        return scoped(
            "oauthCancelBarButtonItem",
            factory: UIBarButtonItem.cancel(target: oauthFlow(), action: Selector("cancel"))
        )
    }
}
