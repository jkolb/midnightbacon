//
//  MeRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/14/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

class MeRequest : APIRequest {
    func build(prototype: NSMutableURLRequest) -> NSMutableURLRequest {
        return prototype.GET("/api/me.json")
    }
    
    var requiresModhash : Bool {
        return false
    }
    
    var scope : OAuthScope? {
        return nil
    }
}
