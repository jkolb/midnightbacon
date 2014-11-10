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
    let reddit: Reddit
    let secureStore: SecureStore
    let session: Session?
    var votePromises = [Link:Promise<Bool>](minimumCapacity: 8)
    var voteFailure: ((error: Error, key: NSIndexPath) -> ())?
    var credentialFactory: () -> Promise<NSURLCredential>
    var credentialPromise: Promise<NSURLCredential>?
    
    init(reddit: Reddit, credentialFactory: () -> Promise<NSURLCredential>, secureStore: SecureStore) {
        self.reddit = reddit
        self.credentialFactory = credentialFactory
        self.secureStore = secureStore
    }
    
    func voteLink(link: Link, direction: VoteDirection, key: NSIndexPath) {
        if let session = self.session {
            votePromises[link] = reddit.vote(session: session, link: link, direction: direction).catch(self, { (context, error) in
                println(error)
                context.voteFailure?(error: error, key: key)
            }).finally(self, { (context) in
                context.votePromises[link] = nil
            })
        } else if let promise = credentialPromise {
            
        } else {
            credentialPromise = credentialFactory()
        }
    }
}
