//
//  SubmitDataController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 5/9/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import FranticApparatus
import Common
import Reddit
import ModestProposal

protocol SubmitDataControllerDelegate : class {
    func submitDataController(submitDataController: SubmitDataController, didFinishWithOutcome outcome: Outcome<Bool, Error>)
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
            dataController.delegate?.submitDataController(self, didFinishWithOutcome: Outcome(success))
        }).catch(self, { (dataController, reason) -> () in
            dataController.delegate?.submitDataController(self, didFinishWithOutcome: Outcome(reason))
        })
    }
    
    func sendSubmitRequest(request: APIRequestOf<Bool>, forceRefresh: Bool = false) -> Promise<Bool> {
        return oauthService.aquireAccessToken(forceRefresh: forceRefresh).then(self, { (dataController, accessToken) -> Result<Bool> in
            return Result(dataController.gateway.performRequest(request, accessToken: accessToken))
        }).recover(self, { (interactor, error) -> Result<Bool> in
            switch error {
            case let unauthorizedError as UnauthorizedError:
                if forceRefresh {
                    return Result(error)
                } else {
                    return Result(interactor.sendSubmitRequest(request, forceRefresh: true))
                }
            default:
                return Result(error)
            }
        })
    }
}
