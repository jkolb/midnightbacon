//
//  GetCaptchaRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/22/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation
import ModestProposal
import FranticApparatus

class GetCaptchaRequest : APIRequest {
    let iden: String
    
    init(iden: String) {
        self.iden = iden
    }
    
    typealias ResponseType = Bool
    
    func parse(response: URLResponse, mapperFactory: RedditFactory) -> Outcome<Bool, Error> {
        return redditJSONMapper(response) { (json) -> Outcome<Bool, Error> in
            println(json)
            return Outcome(true)
        }
    }
    
    func build(prototype: NSURLRequest) -> NSMutableURLRequest {
        return prototype.GET("/captcha/\(iden)")
    }
    
    var requiresModhash : Bool {
        return false
    }
    
    var scope : OAuthScope? {
        return .Identity // Should be "any" not sure what that means yet
    }
}
