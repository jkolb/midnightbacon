//
//  SubmitDataController.swift
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

import FranticApparatus
import Common
import Reddit
import ModestProposal

protocol SubmitDataControllerDelegate : class {
    func submitDataControllerDidComplete(submitDataController: SubmitDataController)
    func submitDataController(submitDataController: SubmitDataController, didFailWithError error: ErrorType)
}

class SubmitDataController {
    var redditRequest: RedditRequest!
    var oauthService: OAuthService!
    var gateway: Gateway!
    weak var delegate: SubmitDataControllerDelegate?
    var promise: Promise<Bool>?
    
    func sendSubmitForm(form: SubmitForm) {
        let request = redditRequest.submit(
            kind: form.kind,
            subreddit: form.subredditField.value ?? "",
            title: form.titleField.value ?? "",
            url: form.urlField?.value,
            text: form.textField?.value,
            sendReplies: form.sendRepliesField.value ?? false
        )
        promise = sendSubmitRequest(request).then(self, { (dataController, success) -> () in
            dataController.delegate?.submitDataControllerDidComplete(self)
        }).handle(self, { (dataController, reason) -> () in
            dataController.delegate?.submitDataController(self, didFailWithError: reason)
        })
    }
    
    func sendSubmitRequest(request: APIRequestOf<Bool>, forceRefresh: Bool = false) -> Promise<Bool> {
        return oauthService.aquireAccessToken(forceRefresh: forceRefresh).then(self, { (dataController, accessToken) -> Result<Bool> in
            return .Deferred(dataController.gateway.performRequest(request, accessToken: accessToken))
        }).recover(self, { (interactor, error) -> Result<Bool> in
            switch error {
            case RedditAPIError.Unauthorized:
                if forceRefresh {
                    return .Failure(error)
                } else {
                    return .Deferred(interactor.sendSubmitRequest(request, forceRefresh: true))
                }
            default:
                return .Failure(error)
            }
        })
    }
}
