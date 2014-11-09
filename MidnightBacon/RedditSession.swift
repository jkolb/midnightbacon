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

    init(reddit: Reddit, secureStore: SecureStore) {
        self.reddit = reddit
        self.secureStore = secureStore
    }
    
    func voteLink(link: Link, direction: VoteDirection, key: NSIndexPath) {
        if let session = self.session {
            votePromises[link] = reddit.vote(session: session, link: link, direction: direction).catch(self, { (context, error) in
                println(error)
                context.voteFailure?(error: error, key: key)
            }).finally(self, { (context) in
            })
        } else {
            
        }
    }
}
