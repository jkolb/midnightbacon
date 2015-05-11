//
//  VoteRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/30/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation
import ModestProposal
import FranticApparatus
import Common

class VoteRequest : APIRequest {
    let prototype: NSURLRequest
    let id: String
    let direction: VoteDirection
    let apiType: APIType
    
    convenience init(prototype: NSURLRequest, link: Link, direction: VoteDirection, apiType: APIType = .JSON) {
        self.init(prototype: prototype, id: link.name, direction: direction, apiType: apiType)
    }
    
    init(prototype: NSURLRequest, id: String, direction: VoteDirection, apiType: APIType = .JSON) {
        self.prototype = prototype
        self.id = id
        self.direction = direction
        self.apiType = apiType
    }
    
    typealias ResponseType = Bool
    
    func parse(response: URLResponse) -> Outcome<Bool, Error> {
        return redditJSONMapper(response) { (json) -> Outcome<Bool, Error> in
            return Outcome(true)
        }
    }
    
    func build() -> NSMutableURLRequest {
        var parameters = [String:String](minimumCapacity: 3)
        parameters["id"] = id
        parameters["dir"] = direction.stringValue
        parameters["api_type"] = apiType.rawValue
        return prototype.POST("/api/vote", parameters: parameters)
    }
    
    var requiresModhash : Bool {
        return true
    }
    
    var scope : OAuthScope? {
        return .Vote
    }
}
