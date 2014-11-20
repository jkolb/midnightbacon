//
//  RedditSession.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/9/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

class RedditSession {
    let reddit: Gateway
    let secureStore: SecureStore
    var insecureStore: InsecureStore
    var sessionPromise: Promise<Session>?
    var credentialFactory: () -> Promise<NSURLCredential>
    
    convenience init(services: Services, credentialFactory: () -> Promise<NSURLCredential>) {
        self.init(reddit: services.gateway, credentialFactory: credentialFactory, secureStore: services.secureStore, insecureStore: services.insecureStore)
    }
    
    init(reddit: Gateway, credentialFactory: () -> Promise<NSURLCredential>, secureStore: SecureStore, insecureStore: InsecureStore) {
        self.reddit = reddit
        self.credentialFactory = credentialFactory
        self.secureStore = secureStore
        self.insecureStore = insecureStore
    }
    
    func store(credential: NSURLCredential, _ session: Session) -> Promise<Session> {
        return secureStore.save(credential, session).when(self, { (context, success) -> Result<Session> in
            return .Success(session)
        }).recover(self, { (context, error) -> Result<Session> in
            println(error)
            return .Success(session)
        })
    }
    
    func addUser() -> Promise<Bool> {
        return credentialFactory().when(self, { (context, credential) -> Result<Bool> in
            return .Deferred(context.addCredential(credential))
        })
    }
    
    func addCredential(credential: NSURLCredential) -> Promise<Bool> {
        let username = credential.user!
        let password = credential.password!
        return reddit.login(username: username, password: password).when(self, { (context, session) -> Result<Session> in
            return .Deferred(context.store(credential, session))
        }).when({ (session) -> Result<Bool> in
            return .Success(true)
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
        return credentialFactory().when(self, { (context, credential) -> Result<Session> in
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
    
    func voteLink(link: Link, direction: VoteDirection) -> Promise<Bool> {
        return openSession(required: true).when(self, { (context, session) -> Result<Bool> in
            return .Deferred(context.reddit.vote(session: session, link: link, direction: direction))
        }).recover(self, { (context, error) -> Result<Bool> in
            println(error)
            switch error {
            case let redditError as RedditError:
                if redditError.requiresReauthentication {
                    context.sessionPromise = nil
                    return .Deferred(context.voteLink(link, direction: direction))
                } else {
                    return .Failure(error)
                }
            default:
                return .Failure(error)
            }
        })
    }
    
    func fetchReddit(path: String, query: [String:String] = [:]) -> Promise<Listing<Link>> {
        return openSession(required: false).when(self, { (context, session) -> Result<Listing<Link>> in
            return .Deferred(context.reddit.fetchReddit(session: session, path: path, query: query))
        }).recover(self, { (context, error) -> Result<Listing<Link>> in
            println(error)
            switch error {
            case let redditError as RedditError:
                if redditError.requiresReauthentication {
                    context.sessionPromise = nil
                    return .Deferred(context.fetchReddit(path, query: query))
                } else {
                    return .Failure(error)
                }
            default:
                return .Failure(error)
            }
        })
    }
}
