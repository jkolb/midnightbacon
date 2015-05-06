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
import Common

class GetCaptchaRequest : APIRequest {
    let prototype: NSURLRequest
    let iden: String
    
    init(prototype: NSURLRequest, iden: String) {
        self.prototype = prototype
        self.iden = iden
    }
    
    typealias ResponseType = UIImage
    
    func parse(response: URLResponse) -> Outcome<UIImage, Error> {
        return redditImageParser(response)
    }
    
    func build() -> NSMutableURLRequest {
        return prototype.GET("/captcha/\(iden)")
    }
    
    var requiresModhash : Bool {
        return false
    }
    
    var scope : OAuthScope? {
        return nil
    }
}
