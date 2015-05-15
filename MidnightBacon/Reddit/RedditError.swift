//
//  RedditError.swift
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
import ModestProposal

class RedditError : Error {
    let name: String
    let explanation: String
    
    init(name: String, explanation: String) {
        self.name = name
        self.explanation = explanation
        super.init(message: "\(name) - \(explanation)")
    }
    
    var failedAuthentication: Bool {
        return true
    }
    
    var requiresReauthentication: Bool {
        return isUserRequired
    }
    
    var isRateLimit: Bool {
        return name == "RATELIMIT"
    }
    
    var isWrongPassword: Bool {
        return name == "WRONG_PASSWORD"
    }
    
    var isUserRequired: Bool {
        return name == "USER_REQUIRED"
    }
}

class RateLimitError : RedditError {
    let ratelimit: Double
    
    init(name: String, explanation: String, ratelimit: Double) {
        self.ratelimit = ratelimit
        super.init(name: name, explanation: explanation)
    }
    
    override var description: String {
        return "\(super.description) (\(ratelimit))"
    }
}

func redditErrorMapper(json: JSON) -> RedditError {
    let errors = json[KeyPath("json.errors")]
    let firstError = errors[0]
    let name = firstError[0].asString ?? ""
    let explanation = firstError[1].asString ?? ""
    
    if name == "RATELIMIT" {
        let ratelimit = json[KeyPath("json.ratelimit")].asDouble ?? 10.0
        return RateLimitError(name: name, explanation: explanation, ratelimit: ratelimit)
    } else {
        return RedditError(name: name, explanation: explanation)
    }
}

func isRedditErrorJSON(json: JSON) -> Bool {
    return json[KeyPath("json.errors")].count > 0
}
