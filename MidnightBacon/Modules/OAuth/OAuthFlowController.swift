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
    var promise: Promise<OAuthAccessToken>?
    
    var accessToken: OAuthAccessToken!
    var account: Account!
    
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
        viewController.title = "Add Account"
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
            handleSuccessfulAuthorizeResponse(valueWrapper.unwrap)
        case .Failure(let errorWrapper):
            handleFailedAuthorizeResponse(errorWrapper.unwrap)
        }
    }
    
    func handleSuccessfulAuthorizeResponse(authorizeResponse: OAuthAuthorizeResponse) {
        if let request = promise {
            return
        }
        
        let authorizeRequest = OAuthAuthorizationCodeRequest(clientID: clientID, authorizeResponse: authorizeResponse, redirectURI: redirectURI)
        promise = gateway.performRequest(authorizeRequest, session: nil).then(self, { (strongSelf, accessToken) -> Result<Account> in
            strongSelf.accessToken = accessToken
            return Result(strongSelf.oauthGateway.performRequest(MeRequest(), accessToken: accessToken))
        }).then(self, { (strongSelf, account) -> Result<OAuthAccessToken> in
            strongSelf.account = account
            return Result(strongSelf.secureStore.saveAccessToken(strongSelf.accessToken, forUsername: strongSelf.account.name))
        }).then(self, { (strongSelf, accessToken) -> () in
            strongSelf.insecureStore.lastAuthenticatedUsername = strongSelf.account.name
        }).catch(self, { (strongSelf, error) -> () in
            strongSelf.displayError(error)
        }).finally(self, { (strongSelf) -> () in
            strongSelf.promise = nil
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
