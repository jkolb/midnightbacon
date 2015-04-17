//
//  OAuthFlowController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 2/25/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

protocol OAuthFlowControllerDelegate : class {
    func oauthFlowControllerDidCancel(oauthFlowController: OAuthFlowController)
    func oauthFlowController(oauthFlowController: OAuthFlowController, didCompleteWithResponse response: OAuthAuthorizeResponse)
}

class OAuthFlowController : NavigationFlowController, WebViewControllerDelegate {
    weak var delegate: OAuthFlowControllerDelegate!
    weak var factory: MainFactory!
    
    let baseURL = NSURL(string: "https://www.reddit.com/")!
    let clientID = "fnOncggIlO7nwA"
    let redirectURI = NSURL(string: "midnightbacon://oauth_redirect")!
    let duration = TokenDuration.Permanent
    let scope: [OAuthScope] = [.Read, .PrivateMessages, .Vote]
    let state: String = NSUUID().UUIDString
    
    func authorizeURL() -> NSURL {
        let request = AuthorizeRequest(clientID: clientID, state: state, redirectURI: redirectURI, duration: duration, scope: scope)
        return request.buildURL(baseURL)!
    }
    
    override func viewControllerDidLoad() {
        navigationController.pushViewController(oauthLoginViewController(), animated: false)
    }
    
    func oauthLoginViewController() -> UIViewController {
        let viewController = WebViewController()
        viewController.style = factory.style()
        viewController.title = "OAuth"
        viewController.url = authorizeURL()
        viewController.delegate = self
        viewController.webViewConfiguration = factory.webViewConfiguration()
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.cancel(target: self, action: Selector("didCancel"))
        return viewController
    }

    func didCancel() {
        delegate.oauthFlowControllerDidCancel(self)
    }
    
    func webViewController(viewController: WebViewController, handleApplicationURL URL: NSURL) {
        let responseOutcome = OAuthAuthorizeResponse.parseFromQuery(URL, expectedState: state)
        switch responseOutcome {
        case .Success(let valueWrapper):
            delegate.oauthFlowController(self, didCompleteWithResponse: valueWrapper.unwrap)
        case .Failure(let errorWrapper):
            print(errorWrapper.unwrap)
        }
    }
}
