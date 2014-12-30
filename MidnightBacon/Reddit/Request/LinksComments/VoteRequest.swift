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

class VoteRequest : APIRequest {
    let id: String
    let direction: VoteDirection
    let apiType: APIType
    
    convenience init(link: Link, direction: VoteDirection, apiType: APIType = .JSON) {
        self.init(id: link.name, direction: direction, apiType: apiType)
    }
    
    init(id: String, direction: VoteDirection, apiType: APIType = .JSON) {
        self.id = id
        self.direction = direction
        self.apiType = apiType
    }
    
    typealias ResponseType = Bool
    
    func parse(response: URLResponse, mapperFactory: RedditFactory) -> Outcome<Bool, Error> {
        return redditJSONMapper(response) { (json) -> Outcome<Bool, Error> in
            println(json)
            return .Success(true)
        }
    }
    
    func build(prototype: NSURLRequest) -> NSMutableURLRequest {
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
