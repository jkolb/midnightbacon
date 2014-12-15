//
//  ClearSessionsRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/14/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

class ClearSessionsRequest : APIRequest {
    let currentPassword: String
    let destinationURL: NSURL
    let apiType: APIType
    
    init(currentPassword: String, destinationURL: NSURL, apiType: APIType = .JSON) {
        self.currentPassword = currentPassword
        self.destinationURL = destinationURL
        self.apiType = apiType
    }
    
    func build(builder: HTTPRequestBuilder) -> NSMutableURLRequest {
        var parameters = [String:String](minimumCapacity: 3)
        parameters["api_type"] = apiType.rawValue
        parameters["curpass"] = currentPassword
        parameters["before"] = destinationURL.absoluteString
        return builder.POST("/api/clear_sessions", parameters: parameters)
    }
    
    var requiresModhash : Bool {
        return true
    }

    var scope : OAuthScope? {
        return nil
    }
}
