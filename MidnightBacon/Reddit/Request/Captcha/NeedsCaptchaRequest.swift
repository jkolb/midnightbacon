//
//  NeedsCaptchaRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/22/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation
import ModestProposal
import FranticApparatus
import Common

class NeedsCaptchaRequest : APIRequest {
    let prototype: NSURLRequest
    
    typealias ResponseType = Bool
    
    init(prototype: NSURLRequest) {
        self.prototype = prototype
    }
    
    func parse(response: URLResponse) -> Outcome<Bool, Error> {
        return redditJSONMapper(response) { (json) -> Outcome<Bool, Error> in
            println(json)
            return Outcome(true)
        }
    }
    
    func build() -> NSMutableURLRequest {
        return prototype.GET("/api/needs_captcha")
    }
    
    var requiresModhash : Bool {
        return false
    }
    
    var scope : OAuthScope? {
        return nil
    }
}
