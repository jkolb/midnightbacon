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
    
    func login(credential: NSURLCredential) -> Promise<Session> {
        return reddit.login(username: "", password: "").when(self, { (context, session) -> Result<Session> in
            // Store credential and session into secure store using a promise
            return .Success(session)
        }).recover(self, { (context, error) -> Result<Session> in
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
    
    // Not saving credential to secure store
    // Not deleting credential from secure store when it fails
    // Not handling storing/retrieving of session from secure store (should check this before credential)
    // With current system would have to dismiss login view controller before proceeding which might be awkward as it would keep popping up on failure (maybe change to not use promises for asking the user?)
    
    func askUserForCredential() -> Promise<Session> {
        return credentialFactory().when(self, { (context, credential) -> Result<Session> in
            return .Deferred(context.login(credential))
        })
    }
    
    func openSession() -> Promise<Session> {
        if let promise = sessionPromise {
            return promise
        } else {
            sessionPromise = secureStore.retrieveCredential().when(self, { (context, credential) -> Result<Session> in
                return .Deferred(context.login(credential))
            }).recover(self, { (context, error) -> Result<Session> in
                switch error {
                case is NoCredentialError:
                    return .Deferred(context.askUserForCredential())
                default:
                    return .Failure(error)
                }
            })
            return sessionPromise!
        }
    }
    
    func voteLink(link: Link, direction: VoteDirection) -> Promise<Bool> {
        return openSession().when(self, { (context, session) -> Result<Bool> in
            return .Deferred(context.reddit.vote(session: session, link: link, direction: direction))
        }).recover(self, { (context, error) -> Result<Bool> in
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
