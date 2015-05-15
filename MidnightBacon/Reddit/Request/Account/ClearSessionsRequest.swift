//
//  ClearSessionsRequest.swift
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
