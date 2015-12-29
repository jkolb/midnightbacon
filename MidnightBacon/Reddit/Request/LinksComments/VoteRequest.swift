//
//  VoteRequest.swift
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
    
    func parse(response: URLResponse) throws -> Bool {
        return try redditJSONMapper(response) { (object) -> Bool in
            return true
        }
    }
    
    func build() -> NSMutableURLRequest {
        var parameters = [String:String](minimumCapacity: 3)
        parameters["id"] = id
        parameters["dir"] = direction.stringValue
        parameters["api_type"] = apiType.rawValue
        return prototype.POST(path: "/api/vote", parameters: parameters)
    }
    
    var requiresModhash : Bool {
        return true
    }
    
    var scope : OAuthScope? {
        return .Vote
    }
}
