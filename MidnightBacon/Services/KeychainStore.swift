//
//  KeychainStore.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/12/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

class KeychainStore : SecureStore, Synchronizable {
    let synchronizationQueue: DispatchQueue = GCDQueue.concurrent("net.franticapparatus.KeychainStore")
    var keychain = Keychain()
    
    func loadCredential(username: String) -> Promise<NSURLCredential> {
        return Promise<NSURLCredential> { (fulfill, reject, isCancelled) in
            synchronizeRead(self) { (synchronizedSelf) in
                let result = synchronizedSelf.keychain.loadGenericPassword(service: "reddit_password", account: username)
                switch result {
                case .Success(let dataClosure):
                    let data = dataClosure.unwrap
                    
                    if let password = data.UTF8String {
                        let credential = NSURLCredential(user: username, password: password, persistence: .None)
                        fulfill(credential)
                    } else {
                        let credential = NSURLCredential(user: username, password: "", persistence: .None)
                        fulfill(credential)
                    }
                case .Failure(let error):
                    reject(NoCredentialError(cause: error))
                }
            }
        }
    }
    
    func loadSession(username: String) -> Promise<Session> {
        return Promise<Session> { (fulfill, reject, isCancelled) in
            synchronizeRead(self) { (synchronizedSelf) in
                let sessionResult = synchronizedSelf.keychain.loadGenericPassword(service: "reddit_session", account: username)
                switch sessionResult {
                case .Success(let dataClosure):
                    let data = dataClosure.unwrap
                    fulfill(Session.secureData(data))
                case .Failure(let error):
                    reject(NoSessionError(cause: error))
                }
            }
        }
    }
    
    func save(credential: NSURLCredential, _ session: Session) -> Promise<Bool> {
        return Promise<Bool> { (fulfill, reject, isCancelled) in
            synchronizeWrite(self) { (synchronizedSelf) in
                let username = credential.user!
                
                if let sessionData = session.secureData {
                    synchronizedSelf.keychain.saveGenericPassword(service: "reddit_session", account: username, data: sessionData)
                }
                
                if let passwordData = credential.secureData {
                    synchronizedSelf.keychain.saveGenericPassword(service: "reddit_password", account: username, data: passwordData)
                }
                
                fulfill(true)
            }
        }
    }
    
    func deleteSession(username: String) -> Promise<Bool> {
        return delete(service: "reddit_session", username: username)
    }
    
    func deleteCredential(username: String) -> Promise<Bool> {
        return delete(service: "reddit_password", username: username)
    }
    
    func delete(# service: String, username: String) -> Promise<Bool> {
        return Promise<Bool> { (fulfill, reject, isCancelled) in
            synchronizeWrite(self) { (synchronizedSelf) in
                let result = synchronizedSelf.keychain.deleteGenericPassword(service: service, account: username)
                switch result {
                case .Success:
                    fulfill(true)
                case .Failure(let error):
                    reject(NoSessionError(cause: error))
                }
            }
        }
    }
    
    func findUsernames() -> Promise<[String]> {
        return Promise<[String]> { (fulfill, reject, isCancelled) in
            synchronizeRead(self) { (synchronizedSelf) in
                let result = synchronizedSelf.keychain.findGenericPassword(service: "reddit_password")
                switch result {
                case .Success(let itemsClosure):
                    let items = itemsClosure.unwrap
                    var usernames = [String]()
                    
                    for item in items {
                        if let username = item.account {
                            usernames.append(username)
                        }
                    }
                    
                    fulfill(usernames)
                case .Failure(let error):
                    reject(error)
                }
            }
        }
    }
}
