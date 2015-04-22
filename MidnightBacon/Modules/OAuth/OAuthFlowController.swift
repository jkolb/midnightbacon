//
//  OAuthFlowController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 2/25/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

protocol OAuthFlowControllerDelegate : class {
    func oauthFlowControllerDidCancel(oauthFlowController: OAuthFlowController)
    func oauthFlowController(oauthFlowController: OAuthFlowController, didCompleteWithResponse response: OAuthAuthorizeResponse)
}

class OAuthFlowController : NavigationFlowController, WebViewControllerDelegate {
    weak var delegate: OAuthFlowControllerDelegate!
    weak var factory: MainFactory!
    var gateway: Gateway!
    var oauthGateway: OAuthGateway!
    var secureStore: SecureStore!
    var insecureStore: InsecureStore!
    var logger: Logger!
    var promise: Promise<OAuthAccessToken>?
    
    var accessToken: OAuthAccessToken!
    var account: Account!
    
    let baseURL = NSURL(string: "https://www.reddit.com/")!
    let clientID = "fnOncggIlO7nwA"
    let redirectURI = NSURL(string: "midnightbacon://oauth_redirect")!
    let duration = TokenDuration.Permanent
    let scope: [OAuthScope] = [
        .Account,
        .Edit,
        .History,
        .Identity,
        .MySubreddits,
        .PrivateMessages,
        .Read,
        .Report,
        .Save,
        .Submit,
        .Subscribe,
        .Vote
    ]
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
        viewController.title = "Add Account"
        viewController.url = authorizeURL()
        viewController.delegate = self
        viewController.webViewConfiguration = factory.webViewConfiguration()
        viewController.logger = logger
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
            handleSuccessfulAuthorizeResponse(valueWrapper.unwrap)
        case .Failure(let errorWrapper):
            handleFailedAuthorizeResponse(errorWrapper.unwrap)
        }
    }
    
    func handleSuccessfulAuthorizeResponse(authorizeResponse: OAuthAuthorizeResponse) {
        if let request = promise {
            return
        }
        // Show activity
        
        let authorizeRequest = OAuthAuthorizationCodeRequest(clientID: clientID, authorizeResponse: authorizeResponse, redirectURI: redirectURI)
        promise = gateway.performRequest(authorizeRequest, session: nil).then(self, { (strongSelf, accessToken) -> Result<Account> in
            strongSelf.logger.debug("API returned access token \(accessToken)")
            strongSelf.accessToken = accessToken
            return Result(strongSelf.oauthGateway.performRequest(MeRequest(), accessToken: accessToken))
        }).then(self, { (strongSelf, account) -> Result<OAuthAccessToken> in
            strongSelf.logger.debug("API returned account \(account)")
            strongSelf.account = account
            return Result(strongSelf.secureStore.saveAccessToken(strongSelf.accessToken, forUsername: strongSelf.account.name))
        }).then(self, { (strongSelf, accessToken) -> () in
            strongSelf.logger.debug("Stored access token")
            strongSelf.insecureStore.lastAuthenticatedUsername = strongSelf.account.name
        }).catch(self, { (strongSelf, error) -> () in
            strongSelf.logger.error("\(error)")
            strongSelf.displayError(error)
        }).finally(self, { (strongSelf) -> () in
            strongSelf.promise = nil
            // Hide activity
            strongSelf.delegate?.oauthFlowController(strongSelf, didCompleteWithResponse: authorizeResponse)
        })
    }
    
    func handleFailedAuthorizeResponse(error: Error) {
        displayError(error)
    }
    
    func displayError(error: Error) {
        let alertView = UIAlertView(title: "Error", message: error.description, delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
    }
}
