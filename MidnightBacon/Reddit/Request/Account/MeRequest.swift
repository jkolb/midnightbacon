//
//  MeRequest.swift
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

class MeRequest : APIRequest {
    let mapperFactory: RedditFactory
    let prototype: NSURLRequest
    
    typealias ResponseType = Account
    
    init(mapperFactory: RedditFactory, prototype: NSURLRequest) {
        self.mapperFactory = mapperFactory
        self.prototype = prototype
    }
    
    func parse(response: URLResponse) -> Outcome<Account, Error> {
        let mapperFactory = self.mapperFactory
        return redditJSONMapper(response) { (json) -> Outcome<Account, Error> in
            let mapResult = mapperFactory.accountMapper().map(json)
            
            switch mapResult {
            case .Success(let thing):
                if let account = thing.unwrap as? Account {
                    return Outcome(account)
                } else {
                    fatalError("Expected account")
                }
            case .Failure(let error):
                return Outcome(error.unwrap)
            }
        }
        
    }
    
    func build() -> NSMutableURLRequest {
        return prototype.GET("/api/v1/me.json")
    }
    
    var requiresModhash : Bool {
        return false
    }
    
    var scope : OAuthScope? {
        return nil
    }
}
