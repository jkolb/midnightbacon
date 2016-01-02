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

import Jasoom

public class RedditError : ErrorType, CustomStringConvertible {
    public let name: String
    public let explanation: String
    
    public init(name: String, explanation: String) {
        self.name = name
        self.explanation = explanation
    }
    
    public var failedAuthentication: Bool {
        return true
    }
    
    public var requiresReauthentication: Bool {
        return isUserRequired
    }
    
    public var isRateLimit: Bool {
        return name == "RATELIMIT"
    }
    
    public var isWrongPassword: Bool {
        return name == "WRONG_PASSWORD"
    }
    
    public var isUserRequired: Bool {
        return name == "USER_REQUIRED"
    }
    
    public var description: String {
        return "\(name) - \(explanation)"
    }
}

public class RateLimitError : RedditError {
    public let ratelimit: Double
    
    public init(name: String, explanation: String, ratelimit: Double) {
        self.ratelimit = ratelimit
        super.init(name: name, explanation: explanation)
    }
    
    public override var description: String {
        return "\(super.description) (\(ratelimit))"
    }
}

func redditErrorMapper(json: JSON) -> RedditError {
    let errors = json["json"]["errors"]
    let firstError = errors[0]
    let name = firstError[0].textValue ?? ""
    let explanation = firstError[1].textValue ?? ""
    
    if name == "RATELIMIT" {
        let ratelimit = json["json"]["ratelimit"].doubleValue ?? 10.0
        return RateLimitError(name: name, explanation: explanation, ratelimit: ratelimit)
    } else {
        return RedditError(name: name, explanation: explanation)
    }
}

func isRedditErrorJSON(json: JSON) -> Bool {
    return json["json"]["errors"].count > 0
}
