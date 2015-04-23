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
    
    typealias ResponseType = UIImage
    
    func parse(response: URLResponse, mapperFactory: RedditFactory) -> Outcome<UIImage, Error> {
        return redditImageParser(response)
    }
    
    func build(prototype: NSURLRequest) -> NSMutableURLRequest {
        return prototype.GET("/captcha/\(iden)")
    }
    
    var requiresModhash : Bool {
        return false
    }
    
    var scope : OAuthScope? {
        return nil
    }
}
