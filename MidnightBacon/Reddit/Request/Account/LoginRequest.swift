//
//  LoginRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/14/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation
import ModestProposal
import FranticApparatus

class LoginRequest : APIRequest {
    let username: String
    let password: String
    let rememberPastSession: Bool?
    let apiType: APIType
    
    init(username: String, password: String, rememberPastSession: Bool? = nil, apiType: APIType = .JSON) {
        self.username = username
        self.password = password
        self.rememberPastSession = rememberPastSession
        self.apiType = apiType
    }
    
    typealias ResponseType = Session
    
    func parse(response: URLResponse) -> Outcome<Session, Error> {
        return redditJSONMapper(response) { (json) -> Outcome<Session, Error> in
            return Outcome(SessionMapper().fromAPI(json))
        }
    }

    func build(prototype: NSURLRequest) -> NSMutableURLRequest {
        var parameters = [String:String](minimumCapacity: 4)
        parameters["api_type"] = apiType.rawValue
        parameters["passwd"] = password
        parameters["rem"] = String(rememberPastSession)
        parameters["user"] = username
        return prototype.POST("/api/login", parameters: parameters)
    }
    
    var requiresModhash : Bool {
        return false
    }
    
    var scope : OAuthScope? {
        return nil
    }
}
