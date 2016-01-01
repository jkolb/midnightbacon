//
//  OAuthFlowController.swift
//  MidnightBacon
//
// Copyright (c) 2015 Justin Kolb - http://franticapparatus.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import UIKit
import FranticApparatus
import Common
import Reddit

protocol OAuthFlowControllerDelegate : class {
    func oauthFlowControllerDidCancel(oauthFlowController: OAuthFlowController)
    func oauthFlowController(oauthFlowController: OAuthFlowController, didCompleteWithResponse response: OAuthAuthorizeResponse)
}

class OAuthFlowController : NavigationFlowController, WebViewControllerDelegate {
    weak var delegate: OAuthFlowControllerDelegate!
    weak var factory: MainFactory!
    var redditRequest: RedditRequest!
    var gateway: Gateway!
    var secureStore: SecureStore!
    var insecureStore: InsecureStore!
    var logger: Logger!
    var promise: Promise<OAuthAccessToken>?
    
    var accessToken: OAuthAccessToken!
    var account: Account!
    let state: String = NSUUID().UUIDString

    override func viewControllerDidLoad() {
        navigationController.pushViewController(oauthLoginViewController(), animated: false)
    }
    
    func oauthLoginViewController() -> UIViewController {
        let viewController = WebViewController()
        viewController.style = factory.style()
        viewController.title = "Add Account"
        viewController.url = redditRequest.authorizeURL(state)
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
        do {
            let response = try OAuthAuthorizeResponse.parseFromQuery(URL, expectedState: state)
            handleSuccessfulAuthorizeResponse(response)
        }
        catch {
            handleFailedAuthorizeResponse(error)
        }
    }
    
    func handleSuccessfulAuthorizeResponse(authorizeResponse: OAuthAuthorizeResponse) {
        if promise != nil {
            return
        }
        // Show activity
        
        let authorizeRequest = factory.redditRequest().userAccessToken(authorizeResponse)
        promise = gateway.performRequest(authorizeRequest).thenWithContext(self, { (strongSelf, accessToken) -> Promise<Account> in
            strongSelf.logger.debug("API returned access token \(accessToken)")
            strongSelf.accessToken = accessToken
            return strongSelf.gateway.performRequest(strongSelf.factory.redditRequest().userAccount(), accessToken: accessToken)
        }).thenWithContext(self, { (strongSelf, account) -> Promise<OAuthAccessToken> in
            strongSelf.logger.debug("API returned account \(account)")
            strongSelf.account = account
            return strongSelf.secureStore.saveAccessToken(strongSelf.accessToken, forUsername: strongSelf.account.name)
        }).thenWithContext(self, { (strongSelf, accessToken) -> Void in
            strongSelf.logger.debug("Stored access token")
            strongSelf.insecureStore.lastAuthenticatedUsername = strongSelf.account.name
        }).handleWithContext(self, { (strongSelf, error) -> Void in
            strongSelf.logger.error("\(error)")
            strongSelf.displayError(error)
        }).finallyWithContext(self, { (strongSelf) -> Void in
            strongSelf.promise = nil
            // Hide activity
            strongSelf.delegate?.oauthFlowController(strongSelf, didCompleteWithResponse: authorizeResponse)
        })
    }
    
    func handleFailedAuthorizeResponse(error: ErrorType) {
        displayError(error)
    }
    
    func displayError(error: ErrorType) {
        let alertView = UIAlertView(title: "Error", message: "\(error)", delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
    }
}
