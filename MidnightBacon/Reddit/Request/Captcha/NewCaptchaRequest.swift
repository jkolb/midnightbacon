//
//  NewCaptchaRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/22/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation
import ModestProposal
import FranticApparatus
import Common

class NewCaptchaRequest : APIRequest {
    let prototype: NSURLRequest
    let apiType: APIType

    init(prototype: NSURLRequest, apiType: APIType = .JSON) {
        self.prototype = prototype
        self.apiType = apiType
    }
    
    typealias ResponseType = Bool
    
    func parse(response: URLResponse) -> Outcome<Bool, Error> {
        return redditJSONMapper(response) { (json) -> Outcome<Bool, Error> in
            return Outcome(true)
        }
    }
    
    func build() -> NSMutableURLRequest {
        var parameters = [String:String](minimumCapacity: 1)
        parameters["api_type"] = apiType.rawValue
        return prototype.POST("/api/needs_captcha", parameters: parameters)
    }
    
    var requiresModhash : Bool {
        return false
    }
    
    var scope : OAuthScope? {
        return nil
    }
}
