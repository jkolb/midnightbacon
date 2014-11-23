//
//  SessionService.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/22/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

class SessionService {
    var reddit: Gateway!
    var secureStore: SecureStore!
    var insecureStore: InsecureStore!
    var authenticationService: AuthenticationService!
    
    var sessionPromise: Promise<Session>?

    init() {
    }
    
    func store(credential: NSURLCredential, _ session: Session) -> Promise<Session> {
        return secureStore.save(credential, session).when(self, { (context, success) -> Result<Session> in
            return .Success(session)
        }).recover(self, { (context, error) -> Result<Session> in
            println(error)
            return .Success(session)
        })
    }
    
    func login(credential: NSURLCredential) -> Promise<Session> {
        let username = credential.user!
        let password = credential.password!
        return reddit.login(username: username, password: password).when(self, { (context, session) -> Result<Session> in
            context.insecureStore.lastAuthenticatedUsername = username
            return .Deferred(context.store(credential, session))
        }).recover(self, { (context, error) -> Result<Session> in
            println(error)
            switch error {
            case let redditError as RedditError:
                if redditError.failedAuthentication {
                    return .Deferred(context.askUserForCredential())
                } else {
                    return .Failure(error)
                }
            default:
                return .Failure(error)
            }
        })
    }
    
    func logout() -> Promise<Bool> {
        if let username = insecureStore.lastAuthenticatedUsername {
            return secureStore.deleteSession(username)
        } else {
            let promise = Promise<Bool>()
            promise.fulfill(true)
            return promise
        }
    }
    
    func askUserForCredential() -> Promise<Session> {
        return authenticationService.authenticate().when(self, { (context, credential) -> Result<Session> in
            return .Deferred(context.login(credential))
        })
    }
    
    func authenticate() -> Promise<Session> {
        if let username = insecureStore.lastAuthenticatedUsername {
            return secureStore.loadCredential(username).when(self, { (context, credential) -> Result<Session> in
                return .Deferred(context.login(credential))
            }).recover(self, { (context, error) -> Result<Session> in
                println(error)
                switch error {
                case is NoCredentialError:
                    return .Deferred(context.askUserForCredential())
                default:
                    return .Failure(error)
                }
            })
        } else {
            return askUserForCredential()
        }
    }
    
    func openSession(# required: Bool) -> Promise<Session> {
        if let promise = sessionPromise {
            return promise
        } else {
            if required {
                if let username = insecureStore.lastAuthenticatedUsername {
                    sessionPromise = secureStore.loadSession(username).recover(self, { (context, error) -> Result<Session> in
                        println(error)
                        return .Deferred(context.authenticate())
                    })
                } else {
                    sessionPromise = authenticate()
                }
                return sessionPromise!
            } else {
                let promise = Promise<Session>()
                promise.fulfill(Session.anonymous)
                return promise
            }
        }
    }
    
    func closeSession() {
        sessionPromise = nil
    }
}
