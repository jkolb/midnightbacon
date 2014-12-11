//
//  Reddit.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/1/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus
import ModestProposal

class Reddit : HTTP, Gateway {
    /*
    Optional(<!doctype html><html><title>Ow! -- reddit.com</title><style>body{text-align:center;position:absolute;top:50%;margin:0;margin-top:-275px;width:100%}h2,h3{color:#555;font:bold 200%/100px sans-serif;margin:0}h3{color:#777;font:normal 150% sans-serif}</style><img src=//www.redditstatic.com/heavy-load.png alt=""><h2>we took too long to make this page for you</h2><h3>try again and hopefully we will be fast enough this time.)
    MidnightBacon.UnexpectedHTTPStatusCodeError: Status Code = 504
     */
    /*
    Optional(<!doctype html>
    <html>
    <head>
    
    
    <meta http-equiv="set-cookie" content="cf_use_ob=0; expires=Mon, 03-Nov-14 13:35:38 GMT; path=/">
    
    
    <title>Ow! -- reddit.com</title>
    <script type="text/javascript">
    //<![CDATA[
    *** TOO LONG ***
    <h2>our cdn was unable to reach our servers</h2>
    <h3 style="display: none;"><div class="cf-error-details cf-error-521">
    <h1>Web server is down</h1>
    <p data-translate="not_returning_connection">The web server is not returning a connection. As a result, the web page is not displaying.</p>
    <ul class="cferror_details">
    <li>Ray ID: 1838f4364e481177</li>
    <li>Your IP address: 166.155.215.60</li>
    <li>Error reference number: 521</li>
    <li>CloudFlare Location: Dallas</li>
    </ul>
    </div>
    </h3>
    <h3 style="display: none;">::CLOUDFLARE_ERROR_1000S_BOX::</h3>
    </html>)
    MidnightBacon.UnexpectedHTTPStatusCodeError: Status Code = 521
     */
    
    override init(factory: URLPromiseFactory = URLSessionPromiseFactory()) {
        super.init(factory: factory)
        self.host = "www.reddit.com"
        self.secure = true
        self.userAgent = "MidnightBacon 0.1 iOS 8.1"
    }
    
    func login(# username: String , password: String) -> Promise<Session> {
        let body = HTTP.formURLencoded(
            [
                "api_type": "json",
                "rem": "False",
                "passwd": password,
                "user": username,
            ]
        )
        let request = redditPost("/api/login", body: body)
        return requestParsedJSON(request, parser: parseSession)
    }
    
    func parseError(json: JSON) -> RedditError {
        let errors = json[KeyPath("json.errors")]
        let firstError = errors[0]
        let name = firstError[0].string
        let explanation = firstError[1].string
        
        if name == "RATELIMIT" {
            let number = json[KeyPath("json.ratelimit")].number
            let ratelimit = number.doubleValue
            return RateLimitError(name: name, explanation: explanation, ratelimit: ratelimit)
        } else {
            return RedditError(name: name, explanation: explanation)
        }
    }
    
    func isErrorJSON(json: JSON) -> Bool {
        return json[KeyPath("json.errors")].count > 0
    }
    
    func parseSession(json: JSON) -> ParseResult<Session> {
        println(json)
        let session = Session(
            modhash: json[KeyPath("json.data.modhash")].string,
            cookie: json[KeyPath("json.data.cookie")].string,
            needHTTPS: json[KeyPath("json.data.need_https")].number.boolValue
        )
        return .Success(session)
    }
    
    func redditPost(path: String, body: NSData) -> NSURLRequest {
        let request = post(path: path, body: body)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    func vote(# session: Session, link: Link, direction: VoteDirection) -> Promise<Bool> {
        let body = HTTP.formURLencoded(
            [
                "api_type": "json",
                "dir": direction.stringValue,
                "id": link.name,
            ]
        )
        let request = redditPost("/api/vote", body: body)
        let authenticatedRequest = applySession(session, request: request)
        return requestParsedJSON(authenticatedRequest, parser: parseVote)
    }

    func parseVote(json: JSON) -> ParseResult<Bool> {
        println(json)
        return .Success(true)
    }
    
    func fetchReddit(# session: Session, path: String, query: [String:String] = [:]) -> Promise<Listing<Link>> {
        let request = get(path: "\(path).json", query: query)
        let authenticatedRequest = applySession(session, request: request)
        return requestParsedJSON(authenticatedRequest, parser: parseLinks)
    }
    
    func apiMe(# session: Session) -> Promise<RedditUser> {
        let request = get(path: "/api/me.json")
        let authenticatedRequest = applySession(session, request: request)
        return requestParsedJSON(authenticatedRequest, parser: parseRedditUser)
    }
    
    func requestParsedJSON<T>(request: NSURLRequest, parser: (JSON) -> ParseResult<T>) -> Promise<T> {
        let queue = parseQueue
        let isError = isErrorJSON
        let errorParser = parseError
        return requestJSON(request).when({ (json) -> Result<T> in
//            println(json)
            if isError(json) {
                return .Failure(errorParser(json))
            } else {
                return .Deferred(asyncParse(on: queue, input: json, parser: parser))
            }
        })
    }
    
    func applySession(session: Session, request: NSURLRequest) -> NSURLRequest {
        let sessionRequest = request.mutableCopy() as NSMutableURLRequest
        
        if countElements(session.cookie) > 0 {
            if let cookie = session.cookie.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
                sessionRequest.setValue("reddit_session=" + cookie, forHTTPHeaderField: "Cookie")
            }
        }
        
        if countElements(session.modhash) > 0 {
            sessionRequest.setValue(session.modhash, forHTTPHeaderField: "X-Modhash")
        }
        
        return sessionRequest
    }
    
    func parseRedditUser(json: JSON) -> ParseResult<RedditUser> {
        return .Success(RedditUser())
    }
    
    func parseLinks(json: JSON) -> ParseResult<Listing<Link>> {
        let kind = json["kind"].string
        
        if kind != "Listing" {
            return .Failure(UnexpectedJSONError(message: "Unexpected kind: " + kind))
        }
        
        let listing = json["data"]
        
        if listing.isNull {
            return .Failure(UnexpectedJSONError(message: "Thing missing data"))
        }
        
        let children = listing["children"]
        
        if !children.isArray {
            return .Failure(UnexpectedJSONError(message: "Listing missing children"))
        }
        
        var links = [Link]()
        
        for index in 0..<children.count {
            let childThing = children[index]
            let childKind = childThing["kind"].string
            
            if childKind != "t3" {
                return .Failure(UnexpectedJSONError(message: "Unexpected child kind: " + childKind))
            }
            
            let linkData = childThing["data"]
            
            if linkData.isNull {
                return .Failure(UnexpectedJSONError(message: "Child thing missing data"))
            }
            
            let url = linkData["url"].url
            
            if url == nil {
                println("Skipped link due to invalid URL: " + linkData["url"].string)
                continue
            }
            
            links.append(
                Link(
                    id: linkData["id"].string,
                    name: linkData["name"].string,
                    title: linkData["title"].unescapedString,
                    url: url!,
                    thumbnail: linkData["thumbnail"].string,
                    created: linkData["created_utc"].date,
                    author: linkData["author"].string,
                    domain: linkData["domain"].string,
                    subreddit: linkData["subreddit"].string,
                    commentCount: linkData["num_comments"].integer,
                    permalink: linkData["permalink"].string,
                    over18: linkData["over_18"].boolean,
                    likes: linkData["likes"].voteDirection
                )
            )
        }
        
        return .Success(
            Listing<Link>(
                children: links,
                after: listing["after"].string,
                before: listing["before"].string,
                modhash: listing["modhash"].string
            )
        )
    }
}
