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
    var session: Session? = nil
    var credential: NSURLCredential? = nil
    
    func loadCredential() -> Promise<NSURLCredential> {
        let promise = Promise<NSURLCredential>()
        if let credential = self.credential {
            promise.fulfill(credential)
        } else {
            promise.reject(NoCredentialError())
        }
        return promise
    }
    
    func loadSession() -> Promise<Session> {
        let promise = Promise<Session>()
        if let session = self.session {
            promise.fulfill(session)
        } else {
            promise.reject(NoSessionError())
        }
        return promise
    }
    
    func loadSession(username: String) -> Promise<Session> {
        let promise = Promise<Session>()
        synchronizeRead(self) { [weak promise] (synchronizedSelf) in
            if let strongPromise = promise {
                var sessionItem = Keychain.GenericPassword()
                sessionItem.account = username
                sessionItem.service = "reddit_session"
                let sessionResult = synchronizedSelf.keychain.lookupData(sessionItem)
                switch sessionResult {
                case .Success(let dataClosure):
                    let data = dataClosure()
                    if data.count == 0 {
                        strongPromise.reject(Error(message: "No data found"))
                    } else if data.count > 1 {
                        strongPromise.reject(Error(message: "Too many data found"))
                    } else {
                        strongPromise.fulfill(Session.secureData(data[0]))
                    }
                case .Failure(let error):
                    strongPromise.reject(Error(message: error.status.message))
                }
            }
        }
        return promise
    }
    
    func store(credential: NSURLCredential, _ session: Session) -> Promise<Bool> {
        let promise = Promise<Bool>()
        synchronizeWrite(self) { [weak promise] (synchronizedSelf) in
            if let strongPromise = promise {
                if let account = credential.user {
                    if let sessionData = session.secureData {
                        var sessionItem = Keychain.GenericPassword()
                        sessionItem.account = account
                        sessionItem.service = "reddit_session"
                        let sessionStatus = synchronizedSelf.keychain.addData(sessionItem, data: sessionData)
                        println(sessionStatus)
                    }

                    if let credentialData = credential.secureData {
                        var credentialItem = Keychain.InternetPassword()
                        credentialItem.account = account
                        credentialItem.server = Reddit().host
                        credentialItem.internetProtocol = .HTTPS
                        let credentialStatus = synchronizedSelf.keychain.addData(credentialItem, data: credentialData)
                        println(credentialStatus)
                    }
                    
                    strongPromise.fulfill(true)
                } else {
                    strongPromise.reject(Error(message: "Missing username"))
                }
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
