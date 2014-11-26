//
//  AddAccountInteractor.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/25/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

class AddAccountInteractor {
    var gateway: Gateway!
    var secureStore: SecureStore!
    var addAccountPromise: Promise<Bool>!
    
    init() {
    }
    
    func addCredential(credential: NSURLCredential, completion: () -> ()) {
        let username = credential.user!
        let password = credential.password!
        addAccountPromise = gateway.login(username: username, password: password).when(self, { (interactor, session) -> Result<Session> in
            return .Deferred(interactor.store(credential, session))
        }).when(self, { (session) -> Result<Bool> in
            completion()
            return .Success(true)
        })
    }
    
    func store(credential: NSURLCredential, _ session: Session) -> Promise<Session> {
        return secureStore.save(credential, session).when(self, { (context, success) -> Result<Session> in
            return .Success(session)
        }).recover(self, { (context, error) -> Result<Session> in
            println(error)
            return .Success(session)
        })
    }
}
