//
//  SecureStore.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/9/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

class NoCredentialError : Error { }
class NoSessionError : Error { }

protocol SecureStore {
    func store(credential: NSURLCredential, _ session: Session) -> Promise<Bool>
    func loadCredential() -> Promise<NSURLCredential>
    func loadSession() -> Promise<Session>
}
