//
//  SecureStore.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/9/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

class NoCredentialError : Error {
    let cause: Error
    
    init(cause: Error) {
        self.cause = cause
        super.init(message: cause.description)
    }
}
class NoSessionError : Error  {
    let cause: Error
    
    init(cause: Error) {
        self.cause = cause
        super.init(message: cause.description)
    }
}

protocol SecureStore {
    func store(credential: NSURLCredential, _ session: Session) -> Promise<Bool>
    func loadCredential(username: String) -> Promise<NSURLCredential>
    func loadSession(username: String) -> Promise<Session>
}
