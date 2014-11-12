//
//  RedditSession.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/9/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

struct RequestKey {
    let context: String
    let indexPath: NSIndexPath?
}

class RedditSession {
    let reddit: Reddit
    let secureStore: SecureStore
    var sessionPromise: Promise<Session>?
    var credentialFactory: () -> Promise<NSURLCredential>
    var credentialPromise: Promise<NSURLCredential>?
    
    init(reddit: Reddit, credentialFactory: () -> Promise<NSURLCredential>, secureStore: SecureStore) {
        self.reddit = reddit
        self.credentialFactory = credentialFactory
        self.secureStore = secureStore
    }
    
    func store(credential: NSURLCredential, _ session: Session) -> Promise<Session> {
        return secureStore.store(credential, session).when(self, { (context, success) -> Result<Session> in
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
    
    // Not deleting credential from secure store when it fails
    // With current system would have to dismiss login view controller before proceeding which might be awkward as it would keep popping up on failure (maybe change to not use promises for asking the user?)
    
    func askUserForCredential() -> Promise<Session> {
        return credentialFactory().when(self, { (context, credential) -> Result<Session> in
            return .Deferred(context.login(credential))
        })
    }
    
    func authenticate() -> Promise<Session> {
        return secureStore.loadCredential().when(self, { (context, credential) -> Result<Session> in
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
    }
    
    func openSession() -> Promise<Session> {
        if let promise = sessionPromise {
            return promise
        } else {
            sessionPromise = secureStore.loadSession().recover(self, { (context, error) -> Result<Session> in
                println(error)
                return .Deferred(context.authenticate())
            })
            return sessionPromise!
        }
    }
    
    func voteLink(link: Link, direction: VoteDirection) -> Promise<Bool> {
        return openSession().when(self, { (context, session) -> Result<Bool> in
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
}
