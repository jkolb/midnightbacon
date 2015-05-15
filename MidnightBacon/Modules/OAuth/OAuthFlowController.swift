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
        
        let authorizeRequest = factory.redditRequest().userAccessToken(authorizeResponse)
        promise = gateway.performRequest(authorizeRequest).then(self, { (strongSelf, accessToken) -> Result<Account> in
            strongSelf.logger.debug("API returned access token \(accessToken)")
            strongSelf.accessToken = accessToken
            return Result(strongSelf.gateway.performRequest(strongSelf.factory.redditRequest().userAccount(), accessToken: accessToken))
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
