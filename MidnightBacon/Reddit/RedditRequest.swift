//
//  RedditRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 5/5/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation
import Common

public class RedditRequest {
    let clientID = "fnOncggIlO7nwA"
    let redirectURI = NSURL(string: "midnightbacon://oauth_redirect")!
    let mapperFactory = RedditFactory()
    let scope: [OAuthScope] = [
        .Account,
        .Edit,
        .History,
        .Identity,
        .MySubreddits,
        .PrivateMessages,
        .Read,
        .Report,
        .Save,
        .Submit,
        .Subscribe,
        .Vote
    ]
    let duration = TokenDuration.Permanent
    public var tokenPrototype: NSURLRequest!
    public var oauthPrototype: NSURLRequest!
    
    public init() { }
    
    public func authorizeURL(state: String) -> NSURL {
        let request = AuthorizeRequest(clientID: clientID, state: state, redirectURI: redirectURI, duration: duration, scope: scope)
        return request.buildURL(tokenPrototype.URL!)!
    }

    public func userAccessToken(authorizeResponse: OAuthAuthorizeResponse) -> APIRequestOf<OAuthAccessToken> {
        return APIRequestOf(OAuthAuthorizationCodeRequest(mapperFactory: mapperFactory, prototype: tokenPrototype, clientID: clientID, authorizeResponse: authorizeResponse, redirectURI: redirectURI))
    }
    
    public func refreshAccessToken(accessToken: OAuthAccessToken) -> APIRequestOf<OAuthAccessToken> {
        return APIRequestOf(OAuthRefreshTokenRequest(mapperFactory: mapperFactory, prototype: tokenPrototype, clientID: clientID, accessToken: accessToken))
    }
    
    public func applicationAccessToken(deviceID: NSUUID) -> APIRequestOf<OAuthAccessToken> {
        return APIRequestOf(OAuthInstalledClientRequest(mapperFactory: mapperFactory, prototype: tokenPrototype, clientID: clientID, deviceID: deviceID))
    }
    
    public func userAccount() -> APIRequestOf<Account> {
        return APIRequestOf(MeRequest(mapperFactory: mapperFactory, prototype: oauthPrototype))
    }

    public func subredditLinks(path: String, after: String? = nil) -> APIRequestOf<Listing> {
        return APIRequestOf(SubredditRequest(mapperFactory: mapperFactory, prototype: oauthPrototype, path: path, after: after))
    }
    
    public func linkComments(link: Link) -> APIRequestOf<(Listing, [Thing])> {
        return APIRequestOf(CommentsRequest(mapperFactory: mapperFactory, prototype: oauthPrototype, article: link))
    }
}
