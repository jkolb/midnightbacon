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
    
    var promises = [String:Promise<RedditUser>](minimumCapacity: 1)
    
    init() { }
    
    func aboutUser(username: String) -> Promise<RedditUser> {
        if let promise = promises[username] {
            return promise
        }
        
        let promise = sessionService.openSession(required: true).when(self, { (interactor, session) -> Result<RedditUser> in
            return .Deferred(interactor.gateway.aboutUser(session: session, username: username))
        }).finally(self, { (interactor) in
            interactor.promises[username] = nil
        })
        
        return promise
    }
}
