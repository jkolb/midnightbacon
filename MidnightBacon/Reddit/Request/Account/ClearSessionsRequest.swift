//
//  ClearSessionsRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/14/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation
import ModestProposal
import FranticApparatus
import Common

class ClearSessionsRequest : APIRequest {
    let prototype: NSURLRequest
    let currentPassword: String
    let destinationURL: NSURL
    let apiType: APIType
    
    init(prototype: NSURLRequest, currentPassword: String, destinationURL: NSURL, apiType: APIType = .JSON) {
        self.prototype = prototype
        self.currentPassword = currentPassword
        self.destinationURL = destinationURL
        self.apiType = apiType
    }
    
    typealias ResponseType = JSON
    
    func parse(response: URLResponse) -> Outcome<JSON, Error> {
        return redditJSONMapper(response) { (json) -> Outcome<JSON, Error> in
            return Outcome(json)
        }
    }

    func build() -> NSMutableURLRequest {
        var parameters = [String:String](minimumCapacity: 3)
        parameters["api_type"] = apiType.rawValue
        parameters["curpass"] = currentPassword
        parameters["before"] = destinationURL.absoluteString
        return prototype.POST("/api/clear_sessions", parameters: parameters)
    }
    
    var requiresModhash : Bool {
        return true
    }

    var scope : OAuthScope? {
        return nil
    }
}
