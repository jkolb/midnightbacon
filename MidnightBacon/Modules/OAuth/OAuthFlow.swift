//
//  OAuthFlow.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 2/25/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

class OAuthFlow : Flow, WebViewControllerDelegate {
    weak var styleFactory: StyleFactory!
    weak var sharedFactory: SharedFactory!
    weak var presenter: Presenter!
    
    let baseURL = NSURL(string: "https://www.reddit.com/")!
    let clientID = "fnOncggIlO7nwA"
    let redirectURI = NSURL(string: "midnightbacon://oauth_redirect")!
    let duration = TokenDuration.Permanent
    let scope: [OAuthScope] = [.Read, .PrivateMessages, .Vote]

    func authorizeURL() -> NSURL {
        let request = AuthorizeRequest(clientID: clientID, state: NSUUID().UUIDString, redirectURI: redirectURI, duration: duration, scope: scope)
        return request.buildURL(baseURL)!
    }

    override func loadViewController() {
        viewController = UINavigationController(rootViewController: oauthLoginViewController())
    }
    
    func oauthLoginViewController() -> UIViewController {
        let viewController = WebViewController()
        viewController.style = self.styleFactory.style()
        viewController.title = "OAuth"
        viewController.url = authorizeURL()
        viewController.delegate = self
        viewController.webViewConfiguration = self.sharedFactory.webViewConfiguration()
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.cancel(target: self, action: Selector("cancel"))
        return viewController
    }

    func cancel() {
//        stop(presenter)
    }
    
    func webViewController(viewController: WebViewController, handleApplicationURL URL: NSURL) {
        println("Redirected successfully \(URL)")
    }
}
