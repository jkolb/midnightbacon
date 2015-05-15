//
//  SubredditRequest.swift
//  MidnightBacon
//
// Copyright (c) 2015 Justin Kolb - http://franticapparatus.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
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
