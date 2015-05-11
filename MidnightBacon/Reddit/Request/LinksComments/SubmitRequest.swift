//
//  SubmitRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/22/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation
import ModestProposal
import FranticApparatus
import Common

public enum SubmitKind : String {
    case LinkKind = "link"
    case TextKind = "self"
    
    public static func allKinds() -> [SubmitKind] {
        return [.LinkKind, .TextKind]
    }
}

/* SUCCESS (self)
{
    "json": {
    "data": {
        "id": "35jw3e",
        "name": "t3_35jw3e",
        "url": "https://www.reddit.com/r/12AMBacon/comments/35jw3e/first/"
    },
    "errors": []
    }
}
 */
/* SUCCESS (link)
{
    "json": {
    "data": {
        "id": "35jwo4",
        "name": "t3_35jwo4",
        "url": "https://www.reddit.com/r/12AMBacon/comments/35jwo4/test_url/"
    },
    "errors": []
    }
}
 */
class SubmitRequest : APIRequest {
    let prototype: NSURLRequest
    let apiType: APIType            // the string json
    let captcha: String?            // the user's response to the CAPTCHA challenge
    let redirectExtension: String?  // extension used for redirects
    let iden: String?               // the identifier of the CAPTCHA challenge
    let kind: String                // one of (link, self)
    let resubmit: Bool?             // boolean value
    let sendReplies: Bool           // boolean value
    let subreddit: String           // name of a subreddit
    let text: String?               // raw markdown text
    let then: String?               // one of (tb, comments)
    let title: String               // title of the submission. up to 300 characters long
    let url: NSURL?                 // a valid URL
    
    convenience init(prototype: NSURLRequest, kind: SubmitKind, subreddit: String, title: String, url: NSURL?, text: String?, sendReplies: Bool) {
        self.init(
            prototype: prototype,
            apiType: .JSON,
            captcha: nil,
            redirectExtension: nil,
            iden: nil,
            kind: kind.rawValue,
            resubmit: false,
            sendReplies: sendReplies,
            subreddit: subreddit,
            text: text,
            then: nil,
            title: title,
            url: url
        )
    }
    
    init(prototype: NSURLRequest, apiType: APIType, captcha: String?, redirectExtension: String?, iden: String?, kind: String, resubmit: Bool, sendReplies: Bool, subreddit: String, text: String?, then: String?, title: String, url: NSURL?) {
        self.prototype = prototype
        self.apiType = apiType
        self.captcha = captcha
        self.redirectExtension = redirectExtension
        self.iden = iden
        self.kind = kind
        self.resubmit = resubmit
        self.sendReplies = sendReplies
        self.subreddit = subreddit
        self.text = text
        self.then = then
        self.title = title
        self.url = url
    }
    
    typealias ResponseType = Bool
    
    func parse(response: URLResponse) -> Outcome<Bool, Error> {
        return redditJSONMapper(response) { (json) -> Outcome<Bool, Error> in
            return Outcome(true)
        }
    }
    
    func build() -> NSMutableURLRequest {
        var parameters = [String:String](minimumCapacity: 3)
        parameters["api_type"] = apiType.rawValue
        parameters["captcha"] = captcha
        parameters["extension"] = redirectExtension
        parameters["iden"] = iden
        parameters["kind"] = kind
        parameters["resubmit"] = String(resubmit)
        parameters["sendreplies"] = String(sendReplies)
        parameters["sr"] = subreddit
        parameters["text"] = text
        parameters["then"] = then
        parameters["title"] = title
        parameters["url"] = url?.absoluteString
        return prototype.POST("/api/submit", parameters: parameters)
    }
    
    var requiresModhash : Bool {
        return true
    }
    
    var scope : OAuthScope? {
        return .Submit
    }
}
