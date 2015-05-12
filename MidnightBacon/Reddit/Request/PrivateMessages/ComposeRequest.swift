//
//  ComposeRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 5/12/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Common
import ModestProposal
import FranticApparatus

class ComposeRequest : APIRequest {
    let prototype: NSURLRequest
    let apiType: APIType = .JSON
    let captcha: Captcha?
    let fromSubreddit: String?
    let subject: String?
    let text: String?
    let to: String?
    
    init(prototype: NSURLRequest, fromSubreddit: String?, to: String?, subject: String?, text: String?, captcha: Captcha?) {
        self.prototype = prototype
        self.fromSubreddit = fromSubreddit
        self.to = to
        self.subject = subject
        self.text = text
        self.captcha = captcha
    }
    
    typealias ResponseType = Bool
    
    func parse(response: URLResponse) -> Outcome<Bool, Error> {
        return redditJSONMapper(response) { (json) -> Outcome<Bool, Error> in
            return Outcome(true)
        }
    }
    
    func build() -> NSMutableURLRequest {
        var parameters = [String:String](minimumCapacity: 7)
        parameters["api_type"] = apiType.rawValue
        parameters["captcha"] = captcha?.text
        parameters["from_sr"] = fromSubreddit
        parameters["iden"] = captcha?.iden
        parameters["subject"] = subject
        parameters["text"] = text
        parameters["to"] = to
        return prototype.POST("/api/read_message", parameters: parameters)
    }
    
    var requiresModhash : Bool {
        return true
    }
    
    var scope : OAuthScope? {
        return .PrivateMessages
    }
}
