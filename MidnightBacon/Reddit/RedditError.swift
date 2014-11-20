//
//  RedditError.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

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
