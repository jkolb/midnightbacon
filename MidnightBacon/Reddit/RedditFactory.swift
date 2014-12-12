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
    
    func listingMapper() -> ListingMapper {
        return weakShared(
            "listingMapper",
            factory: ListingMapper(),
            configure: { [unowned self] (instance) in
                instance.thingMapper = self.redditMapper()
            }
        )
    }
    
    func redditMapper() -> RedditMapper {
        return weakShared(
            "redditMapper",
            factory: RedditMapper(),
            configure: { [unowned self] (instance) in
                instance.thingMappers = [
                    .Account: self.accountMapper(),
                    .Link: self.linkMapper(),
                ]
            }
        )
    }
}
