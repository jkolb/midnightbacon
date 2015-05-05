//
//  RedditRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 5/5/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation

class RedditRequest {
    let clientID = "fnOncggIlO7nwA"
    let redirectURI = NSURL(string: "midnightbacon://oauth_redirect")!
    let mapperFactory = RedditFactory()
    
    func userAccount() -> APIRequestOf<Account> {
        return APIRequestOf(MeRequest(mapperFactory: mapperFactory))
    }
    
    func userAccessToken(authorizeResponse: OAuthAuthorizeResponse) -> APIRequestOf<OAuthAccessToken> {
        return APIRequestOf(OAuthAuthorizationCodeRequest(mapperFactory: mapperFactory, clientID: clientID, authorizeResponse: authorizeResponse, redirectURI: redirectURI))
    }
    
    func refreshAccessToken(accessToken: OAuthAccessToken) -> APIRequestOf<OAuthAccessToken> {
        return APIRequestOf(OAuthRefreshTokenRequest(mapperFactory: mapperFactory, clientID: clientID, accessToken: accessToken))
    }
    
    func applicationAccessToken(deviceID: NSUUID) -> APIRequestOf<OAuthAccessToken> {
        return APIRequestOf(OAuthInstalledClientRequest(mapperFactory: mapperFactory, clientID: clientID, deviceID: deviceID))
    }

    func subredditLinks(path: String, after: String? = nil) -> APIRequestOf<Listing> {
        return APIRequestOf(SubredditRequest(mapperFactory: mapperFactory, path: path, after: after))
    }
    
    func linkComments(link: Link) -> APIRequestOf<(Listing, [Thing])> {
        return APIRequestOf(CommentsRequest(mapperFactory: mapperFactory, article: link))
    }
}
