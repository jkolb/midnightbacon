//
//  SubredditRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/14/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

class SubredditRequest : APIRequest {
    let name: String
    let after: String?
    let before: String?
    let count: Int?
    let limit: Int?
    
    convenience init(name: String, count: Int? = nil, limit: Int? = nil) {
        self.init(name: name, after: nil, before: nil, count: count, limit: limit)
    }
    
    convenience init(name: String, after: String?, count: Int? = nil, limit: Int? = nil) {
        self.init(name: name, after: after, before: nil, count: count, limit: limit)
    }
    
    convenience init(name: String, before: String?, count: Int? = nil, limit: Int? = nil) {
        self.init(name: name, after: nil, before: before, count: count, limit: limit)
    }
    
    init(name: String, after: String?, before: String? , count: Int?, limit: Int?) {
        self.name = name
        self.after = after
        self.before = before
        self.count = count
        self.limit = limit
    }
    
    func build(builder: HTTPRequestBuilder) -> NSMutableURLRequest {
        var query = [String:String](minimumCapacity: 4)
        query["after"] = after
        query["before"] = before
        query["count"] = String(count)
        query["limit"] = String(limit)
        return builder.GET("/r/\(name)", query: query)
    }
    
    var requiresModhash : Bool {
        return false
    }

    var scope : OAuthScope? {
        return nil
    }
}
