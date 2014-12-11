//
//  RedditUserInteractor.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/9/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

class RedditUserInteractor {
    var gateway: Gateway!
    var sessionService: SessionService!
    var promiseMe: Promise<RedditUser>!
    
    init() { }
    
    func apiMe() -> Promise<RedditUser> {
        if let promise = promiseMe {
            return promise
        }
        
        promiseMe = sessionService.openSession(required: true).when(self, { (interactor, session) -> Result<RedditUser> in
            return .Deferred(interactor.gateway.apiMe(session: session))
        }).finally(self, { (interactor) in
            interactor.promiseMe = nil
        })
        
        return promiseMe
    }
}
