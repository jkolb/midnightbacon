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
class LoginError : Error {
    let errors: JSON
    
    init(_ errors: JSON) {
        self.errors = errors
        super.init(message: "Errors = \(errors)")
    }
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
    class Links {
        var links: [Link]
        var after: String
        var before: String
        var modhash: String
        var lastIndex = 0
        
        class func none() -> Links {
            return Links(links: [], after: "", before: "", modhash: "")
        }
        
        init (links: [Link], after: String, before: String, modhash: String) {
            self.links = links
            self.after = after
            self.before = before
            self.modhash = modhash
        }
        
        var count: Int {
            return links.count
        }
        
        subscript(index: Int) -> Link {
            return links[index]
        }
        
        var last: Link? {
            if count == 0 {
                return nil
            }
            
            return self[lastIndex]
        }
        
        func add(newLinks: Links) {
            after = newLinks.after
            before = newLinks.before
            modhash = newLinks.modhash
            links.extend(newLinks.links)
            lastIndex = count - 1
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
        
        init(id: String, name: String, title: String, url: NSURL, thumbnail: String, created: NSDate, author: String, domain: String, subreddit: String, commentCount: Int, permalink: String) {
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
    
    override init(factory: URLPromiseFactory = URLSessionPromiseFactory()) {
        super.init(factory: factory)
        self.host = "www.reddit.com"
        self.secure = true
        self.userAgent = "MidnightBacon 1.0"
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
        let request = post(path: "/api/login", body: body)
        return requestParsedJSON(request, parser: parseSession)
    }
    
    func parseSession(json: JSON) -> ParseResult<Session> {
        println(json)
        
        if json[KeyPath("json.errors")].count > 0 {
            return .Failure(LoginError(json[KeyPath("json.errors")]))
        } else {
            let session = Session(
                modhash: json[KeyPath("json.data.modhash")].string,
                cookie: json[KeyPath("json.data.cookie")].string,
                needHTTPS: json[KeyPath("json.data.need_https")].number.boolValue
            )
            return .Success(session)
        }
    }
    
    func fetchReddit(path: String, query: [String:String] = [:]) -> Promise<Links> {
        let request = get(path: "\(path).json", query: query)
        return requestParsedJSON(request, parser: parseLinks)
    }
    
    func requestParsedJSON<T>(request: NSURLRequest, parser: (JSON) -> ParseResult<T>) -> Promise<T> {
        let queue = parseQueue
        return requestJSON(request).when { (json) -> Result<T> in
            return .Deferred(asyncParse(on: queue, input: json, parser: parser))
        }
    }
    
    func parseLinks(json: JSON) -> ParseResult<Links> {
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
        
        var links = Array<Reddit.Link>()
        
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
                Reddit.Link(
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
                    permalink: linkData["permalink"].string
                )
            )
        }
        
        return .Success(
            Reddit.Links(
                links: links,
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
}
