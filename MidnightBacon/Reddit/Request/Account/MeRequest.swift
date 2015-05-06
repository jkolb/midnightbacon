//
//  MeRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/14/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
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
