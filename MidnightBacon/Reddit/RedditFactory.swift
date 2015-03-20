//
//  RedditFactory.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/11/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FieryCrucible

class RedditFactory : DependencyFactory {
    func accountMapper() -> AccountMapper {
        return weakShared(
            "accountMapper",
            factory: AccountMapper()
        )
    }
    
    func linkMapper() -> LinkMapper {
        return weakShared(
            "linkMapper",
            factory: LinkMapper()
        )
    }
    
    func moreMapper() -> MoreMapper {
        return weakShared(
            "moreMapper",
            factory: MoreMapper()
        )
    }
    
    func commentMapper() -> CommentMapper {
        return weakShared(
            "commentMapper",
            factory: CommentMapper(),
            configure: { instance in
                instance.listingMapper = self.listingMapper()
            }
        )
    }
    
    func listingMapper() -> ListingMapper {
        return weakShared(
            "listingMapper",
            factory: ListingMapper(),
            configure: { instance in
                instance.thingMapper = self.redditMapper()
            }
        )
    }
    
    func redditMapper() -> RedditMapper {
        return weakShared(
            "redditMapper",
            factory: RedditMapper(),
            configure: { instance in
                instance.thingMappers = [
                    .Account: self.accountMapper(),
                    .Comment: self.commentMapper(),
                    .Link: self.linkMapper(),
                    .More: self.moreMapper(),
                ]
            }
        )
    }
}
