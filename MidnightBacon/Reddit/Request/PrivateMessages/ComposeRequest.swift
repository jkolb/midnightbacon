//
//  ComposeRequest.swift
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
    
    func parse(response: URLResponse) throws -> Bool {
        return try redditJSONMapper(response) { (json) -> Bool in
            return true
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
        return prototype.POST(path: "/api/read_message", parameters: parameters)
    }
    
    var requiresModhash : Bool {
        return true
    }
    
    var scope : OAuthScope? {
        return .PrivateMessages
    }
}
