//
//  RedditFactory.swift
//  MidnightBacon
//
// Copyright (c) 2015 Justin Kolb - http://franticapparatus.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import FieryCrucible

public class RedditFactory : DependencyFactory {
    func accessTokenMapper() -> OAuthAccessTokenMapper {
        return weakShared(
            "accessTokenMapper",
            factory: OAuthAccessTokenMapper()
        )
    }
    
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
