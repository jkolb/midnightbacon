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
    var promiseMe: Promise<Account>!
    
    init() { }
    
    func apiMe() -> Promise<Account> {
        if let promise = promiseMe {
            return promise
        }
        
        promiseMe = sessionService.openSession(required: true).when(self, { (interactor, session) -> Result<Account> in
            return .Deferred(interactor.gateway.performRequest(MeRequest(), session: session))
        }).finally(self, { (interactor) in
            interactor.promiseMe = nil
        })
        
        return promiseMe
    }
}
