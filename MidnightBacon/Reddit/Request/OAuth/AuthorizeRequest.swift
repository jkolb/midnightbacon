//
//  AuthorizeRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/15/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

class AuthorizeRequest : APIRequest {
    func build(builder: HTTPRequestBuilder) -> NSMutableURLRequest {
        return builder.GET("/api/v1/authorize")
    }
    
    var requiresModhash : Bool {
        return false
    }
    
    var scope : OAuthScope? {
        return nil
    }
}
