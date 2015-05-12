//
//  ReadMessageRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 5/12/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Common
import ModestProposal
import FranticApparatus

class ReadMessageRequest : APIRequest {
    let prototype: NSURLRequest
    let id: [String]
    
    init(prototype: NSURLRequest, id: [String]) {
        self.prototype = prototype
        self.id = id
    }
    
    typealias ResponseType = Bool
    
    func parse(response: URLResponse) -> Outcome<Bool, Error> {
        return redditJSONMapper(response) { (json) -> Outcome<Bool, Error> in
            return Outcome(true)
        }
    }
    
    func build() -> NSMutableURLRequest {
        var parameters = [String:String](minimumCapacity: 1)
        parameters["id"] = join(",", id)
        return prototype.POST("/api/read_message", parameters: parameters)
    }
    
    var requiresModhash : Bool {
        return true
    }
    
    var scope : OAuthScope? {
        return .PrivateMessages
    }
}
