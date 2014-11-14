//
//  KeychainStore.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/12/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

class KeychainStore : SecureStore, Synchronizable {
    let synchronizationQueue = GCDQueue.concurrent("net.franticapparatus.KeychainStore")
    var keychain = Keychain()
    
    func loadCredential(username: String) -> Promise<NSURLCredential> {
        let promise = Promise<NSURLCredential>()
        synchronizeRead(self) { [weak promise] (synchronizedSelf) in
            if let strongPromise = promise {
                let sessionResult = synchronizedSelf.keychain.loadGenericPassword(service: "reddit_password", account: username)
                switch sessionResult {
                case .Success(let dataClosure):
                    let data = dataClosure()
                    
                    if let password = data.UTF8String {
                        let credential = NSURLCredential(user: username, password: password, persistence: .None)
                        strongPromise.fulfill(credential)
                    } else {
                        let credential = NSURLCredential(user: username, password: "", persistence: .None)
                        strongPromise.fulfill(credential)
                    }
                case .Failure(let error):
                    strongPromise.reject(NoCredentialError(cause: error))
                }
            }
        }
        return promise
    }
    
    func loadSession(username: String) -> Promise<Session> {
        let promise = Promise<Session>()
        synchronizeRead(self) { [weak promise] (synchronizedSelf) in
            if let strongPromise = promise {
                let sessionResult = synchronizedSelf.keychain.loadGenericPassword(service: "reddit_session", account: username)
                switch sessionResult {
                case .Success(let dataClosure):
                    let data = dataClosure()
                    strongPromise.fulfill(Session.secureData(data))
                case .Failure(let error):
                    strongPromise.reject(NoSessionError(cause: error))
                }
            }
        }
        return promise
    }
    
    func store(credential: NSURLCredential, _ session: Session) -> Promise<Bool> {
        let promise = Promise<Bool>()
        synchronizeWrite(self) { [weak promise] (synchronizedSelf) in
            if let strongPromise = promise {
                let username = credential.user!
                
                if let sessionData = session.secureData {
                    synchronizedSelf.keychain.saveGenericPassword(service: "reddit_session", account: username, data: sessionData)
                }
                
                if let passwordData = credential.secureData {
                    synchronizedSelf.keychain.saveGenericPassword(service: "reddit_password", account: username, data: passwordData)
                }

                strongPromise.fulfill(true)
            }
        }
        return promise
    }
}

extension String {
    var UTF8Data: NSData? {
        if countElements(self) == 0 {
            return nil
        } else {
            return dataUsingEncoding(NSUTF8StringEncoding)
        }
    }
}

extension NSData {
    var UTF8String: String? {
        if length == 0 {
            return nil
        } else {
            return NSString(data: self, encoding: NSUTF8StringEncoding)
        }
    }
}

extension Session {
    var secureData: NSData? {
        return SessionMapper().toData(self)
    }
    
    static func secureData(data: NSData) -> Session {
        return SessionMapper().fromData(data)
    }
}

extension NSURLCredential {
    var secureData: NSData? {
        if let p = password {
            return p.UTF8Data
        } else {
            return nil
        }
    }
}
