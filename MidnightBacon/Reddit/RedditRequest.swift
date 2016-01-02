//
//  RedditRequest.swift
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

import Foundation
import Common

public class RedditRequest {
    let clientID = "Your ClientID goes here"
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
    
    public func submit(kind kind: SubmitKind, subreddit: String, title: String, url: NSURL?, text: String?, sendReplies: Bool) -> APIRequestOf<Bool> {
        return APIRequestOf(SubmitRequest(prototype: oauthPrototype, kind: kind, subreddit: subreddit, title: title, url: url, text: text, sendReplies: sendReplies))
    }
    
    public func privateMessagesWhere(messageWhere: MessageWhere) -> APIRequestOf<Listing> {
        return APIRequestOf(MessageRequest(mapperFactory: mapperFactory, prototype: oauthPrototype, messageWhere: messageWhere, mark: nil, mid: nil, after: nil, before: nil, count: nil, limit: nil, show: nil, expandSubreddits: nil))
    }
}
