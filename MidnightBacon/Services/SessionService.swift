//
//  SessionService.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/22/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

class SessionService {
    var insecureStore: InsecureStore!
    var secureStore: SecureStore!
    var gateway: Gateway!
    var authentication: AuthenticationService!
    
    var sessionPromise: Promise<Session>?

    init() { }
    
    func store(credential: NSURLCredential, _ session: Session) -> Promise<Session> {
        return secureStore.save(credential, session).then(self, { (context, success) -> Result<Session> in
            return Result(session)
        }).recover(self, { (context, error) -> Result<Session> in
            println(error)
            return Result(session)
        })
    }
    
    func login(credential: NSURLCredential) -> Promise<Session> {
        let request = LoginRequest(
            username: credential.user!,
            password: credential.password!,
            rememberPastSession: true,
            apiType: .JSON
        )
        return gateway.performRequest(request, session: nil).then(self, { (context, session) -> Result<Session> in
            context.insecureStore.lastAuthenticatedUsername = request.username
            return Result(context.store(credential, session))
        }).recover(self, { (context, error) -> Result<Session> in
            println(error)
            switch error {
            case let redditError as RedditError:
                if redditError.failedAuthentication {
                    return Result(context.askUserForCredential())
                } else {
                    return Result(error)
                }
            default:
                return Result(error)
            }
        })
    }
    
    func logout() -> Promise<Bool> {
        if let username = insecureStore.lastAuthenticatedUsername {
            return secureStore.deleteSession(username)
        } else {
            let promise = Promise<Bool> { (fulfill, reject, isCancelled) in
                fulfill(true)
            }
            return promise
        }
    }
    
    func askUserForCredential() -> Promise<Session> {
        return authentication.authenticate().then(self, { (context, credential) -> Result<Session> in
            return Result(context.login(credential))
        })
    }
    
    func authenticate() -> Promise<Session> {
        if let username = insecureStore.lastAuthenticatedUsername {
            return secureStore.loadCredential(username).then(self, { (context, credential) -> Result<Session> in
                return Result(context.login(credential))
            }).recover(self, { (context, error) -> Result<Session> in
                println(error)
                switch error {
                case is NoCredentialError:
                    return Result(context.askUserForCredential())
                default:
                    return Result(error)
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
                        return Result(context.authenticate())
                    })
                } else {
                    sessionPromise = authenticate()
                }
                return sessionPromise!
            } else {
                return Promise<Session> { (fulfill, reject, isCancelled) in
                    fulfill(Session.anonymous)
                }
            }
        }
    }
    
    func closeSession() {
        sessionPromise = nil
    }
}
