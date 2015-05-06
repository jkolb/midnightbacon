//
//  SubredditRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/14/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation
import ModestProposal
import FranticApparatus
import Common

class SubredditRequest : APIRequest {
    let mapperFactory: RedditFactory
    let prototype: NSURLRequest
    let path: String
    let after: String?
    let before: String?
    let count: Int?
    let limit: Int?
    
    convenience init(mapperFactory: RedditFactory, prototype: NSURLRequest, path: String, count: Int? = nil, limit: Int? = nil) {
        self.init(mapperFactory: mapperFactory, prototype: prototype, path: path, after: nil, before: nil, count: count, limit: limit)
    }
    
    convenience init(mapperFactory: RedditFactory, prototype: NSURLRequest, path: String, after: String?, count: Int? = nil, limit: Int? = nil) {
        self.init(mapperFactory: mapperFactory, prototype: prototype, path: path, after: after, before: nil, count: count, limit: limit)
    }
    
    convenience init(mapperFactory: RedditFactory, prototype: NSURLRequest, path: String, before: String?, count: Int? = nil, limit: Int? = nil) {
        self.init(mapperFactory: mapperFactory, prototype: prototype, path: path, after: nil, before: before, count: count, limit: limit)
    }
    
    init(mapperFactory: RedditFactory, prototype: NSURLRequest, path: String, after: String?, before: String? , count: Int?, limit: Int?) {
        self.mapperFactory = mapperFactory
        self.prototype = prototype
        self.path = path
        self.after = after
        self.before = before
        self.count = count
        self.limit = limit
    }
    
    typealias ResponseType = Listing
    
    func parse(response: URLResponse) -> Outcome<Listing, Error> {
        let mapperFactory = self.mapperFactory
        return redditJSONMapper(response) { (json) -> Outcome<Listing, Error> in
            return mapperFactory.listingMapper().map(json)
        }
    }

    func build() -> NSMutableURLRequest {
        var parameters = [String:String](minimumCapacity: 4)
        parameters["after"] = after
        parameters["before"] = before
        parameters["count"] = String(count)
        parameters["limit"] = String(limit)
        return prototype.GET("\(path).json", parameters: parameters)
    }
    
    var requiresModhash : Bool {
        return false
    }

    var scope : OAuthScope? {
        return nil
    }
}
