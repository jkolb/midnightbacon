//
//  Reddit.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/1/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus
import ModestProposal

class UnexpectedJSONError : Error { }
class RedditError : Error {
    let name: String
    let explanation: String
    
    init(name: String, explanation: String) {
        self.name = name
        self.explanation = explanation
        super.init(message: "\(name) - \(explanation)")
    }
    
    var requiresReauthentication: Bool {
        return isUserRequired
    }
    
    var isRateLimit: Bool {
        return name == "RATELIMIT"
    }
    
    var isWrongPassword: Bool {
        return name == "WRONG_PASSWORD"
    }
    
    var isUserRequired: Bool {
        return name == "USER_REQUIRED"
    }
}
class RateLimitError : RedditError {
    let ratelimit: Double
    
    init(name: String, explanation: String, ratelimit: Double) {
        self.ratelimit = ratelimit
        super.init(name: name, explanation: explanation)
    }
    
    override var description: String {
        return "\(super.description) (\(ratelimit))"
    }
}

class Listing<T> {
    let children: [T]
    let after: String
    let before: String
    let modhash: String
    
    class func empty() -> Listing {
        return Listing(children: [], after: "", before: "", modhash: "")
    }
    
    init (children: [T], after: String, before: String, modhash: String) {
        self.children = children
        self.after = after
        self.before = before
        self.modhash = modhash
    }
    
    var count: Int {
        return children.count
    }
    
    subscript(index: Int) -> T {
        return children[index]
    }
}

enum VoteDirection {
    case Upvote
    case Downvote
    case None
    
    var stringValue: String {
        switch self {
        case .Upvote:
            return "1"
        case .Downvote:
            return "-1"
        case .None:
            return "0"
        }
    }
}

class Link {
    let id: String
    let name: String
    let title: String
    let url: NSURL
    let thumbnail: String
    let created: NSDate
    let author: String
    let domain: String
    let subreddit: String
    let commentCount: Int
    let permalink: String
    let over18: Bool
    let likes: VoteDirection
    
    init(id: String, name: String, title: String, url: NSURL, thumbnail: String, created: NSDate, author: String, domain: String, subreddit: String, commentCount: Int, permalink: String, over18: Bool, likes: VoteDirection) {
        self.id = id
        self.name = name
        self.title = title
        self.url = url
        self.thumbnail = thumbnail
        self.created = created
        self.author = author
        self.domain = domain
        self.subreddit = subreddit
        self.commentCount = commentCount
        self.permalink = permalink
        self.over18 = over18
        self.likes = likes
    }
    
    var hasThumbnail: Bool {
        return countElements(thumbnail) > 0
    }
}

struct Session {
    let modhash: String
    let cookie: String
    let needHTTPS: Bool
}

class Reddit : HTTP, ImageSource {
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

    var sessionFactory: (() -> Promise<Session>)!
    
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
    
    func fetchReddit(path: String, query: [String:String] = [:]) -> Promise<Listing<Link>> {
        let request = get(path: "\(path).json", query: query)
        return requestParsedJSON(request, parser: parseLinks)
    }
    
    func requestParsedJSON<T>(request: NSURLRequest, parser: (JSON) -> ParseResult<T>) -> Promise<T> {
        let queue = parseQueue
        let isError = isErrorJSON
        let errorParser = parseError
        return requestJSON(request).when({ (json) -> Result<T> in
            if isError(json) {
                return .Failure(errorParser(json))
            } else {
                return .Deferred(asyncParse(on: queue, input: json, parser: parser))
            }
        }).recover({ [weak self] (error) -> Result<T> in
            if let strongSelf = self {
                switch error {
                case let redditError as RedditError:
                    if redditError.requiresReauthentication {
                        return .Deferred(strongSelf.reauthenticate(request, parser: parser))
                    } else {
                        return .Failure(error)
                    }
                default:
                    return .Failure(error)
                }
            } else {
                return .Failure(error)
            }
        })
    }
    
    func reauthenticate<T>(request: NSURLRequest, parser: (JSON) -> ParseResult<T>) -> Promise<T> {
        return sessionFactory().when({ [weak self] (session) in
            if let strongSelf = self {
                let reauthenticatedRequest = strongSelf.applySession(session, request: request)
                return .Deferred(strongSelf.requestParsedJSON(reauthenticatedRequest, parser: parser))
            } else {
                return .Failure(Error(message: "Reddit deinit"))
            }
        })
    }
    
    func applySession(session: Session, request: NSURLRequest) -> NSURLRequest {
        // TODO: Update request with new session
        
//        if countElements(session.modhash) > 0 {
//            request.setValue(session.modhash, forHTTPHeaderField: "X-Modhash")
//        }
        
        return request
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
                    title: linkData["title"].string,
                    url: url!,
                    thumbnail: linkData["thumbnail"].string,
                    created: linkData["created_utc"].date,
                    author: linkData["author"].string,
                    domain: linkData["domain"].string,
                    subreddit: linkData["subreddit"].string,
                    commentCount: linkData["num_comments"].number.integerValue,
                    permalink: linkData["permalink"].string,
                    over18: linkData["over_18"].number.boolValue,
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

extension JSON {
    var date: NSDate {
        return NSDate(timeIntervalSince1970: number.doubleValue)
    }
    
    var url: NSURL? {
        return string.length == 0 ? nil : NSURL(string: string)
    }
    
    var voteDirection: VoteDirection {
        if let nonNilNumber = numberOrNil {
            if nonNilNumber.boolValue {
                return .Upvote
            } else {
                return .Downvote
            }
        } else {
            return .None
        }
    }
}
