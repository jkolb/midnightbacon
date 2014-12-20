//
//  Reddit.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/1/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus
import ModestProposal
import UIKit

class Reddit : Gateway {
    var redditFactory: RedditFactory!
    let promiseFactory: URLPromiseFactory
    let prototype: NSURLRequest
    let parseQueue: DispatchQueue = GCDQueue.concurrent("reddit parsing queue")
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
    
    init(factory: URLPromiseFactory) {
        let prototype = NSMutableURLRequest()
        prototype.URL = NSURL(string: "https://www.reddit.com")
        prototype[.UserAgent] = "12AMBacon/0.1 by frantic_apparatus"
        self.promiseFactory = factory
        self.prototype = prototype
    }

    func requestImage(url: NSURL) -> Promise<UIImage> {
        return requestImage(NSURLRequest(URL: url))
    }
    
    func requestImage(request: NSURLRequest) -> Promise<UIImage> {
        return promiseFactory.promise(request).when(self, { (context, server) -> Result<UIImage> in
            return .Deferred(context.parseImage(server))
        })
    }

    func parseImage(server: (response: NSURLResponse, data: NSData)) -> Promise<UIImage> {
        let promise = Promise<UIImage>()
        return promise
    }
    
    func login(# username: String , password: String) -> Promise<Session> {
        let request = prototype.POST(
            "/api/login",
            parameters: [
                "api_type": "json",
                "rem": "False",
                "passwd": password,
                "user": username,
            ]
        )
        return requestParsedJSON(request, mapper: parseSession)
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
    
    func parseSession(json: JSON) -> Outcome<Session, Error> {
        println(json)
        let session = Session(
            modhash: json[KeyPath("json.data.modhash")].string,
            cookie: json[KeyPath("json.data.cookie")].string,
            needHTTPS: json[KeyPath("json.data.need_https")].number.boolValue
        )
        return .Success(session)
    }
    
    func redditPost(path: String, parameters: [String:String]? = nil) -> NSURLRequest {
        return prototype.POST(path, parameters: parameters)
//        let request = post(path: path, body: body)
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
//        return request
    }
    
    func vote(# session: Session, link: Link, direction: VoteDirection) -> Promise<Bool> {
        let request = prototype.POST(
            "/api/vote",
            parameters: [
                "api_type": "json",
                "dir": direction.stringValue,
                "id": link.name,
            ]
        )
        let authenticatedRequest = applySession(session, request: request)
        return requestParsedJSON(authenticatedRequest, mapper: parseVote)
    }

    func parseVote(json: JSON) -> Outcome<Bool, Error> {
        println(json)
        return .Success(true)
    }
    
    func fetchReddit(# session: Session, path: String, query: [String:String] = [:]) -> Promise<Listing> {
        let request = prototype.GET("\(path).json", parameters: query)
        let authenticatedRequest = applySession(session, request: request)
//        return requestParsedJSON(authenticatedRequest, parser: parseLinks)
        return requestParsedJSON(authenticatedRequest, mapper: redditFactory.listingMapper().map)
    }
    
    func apiMe(# session: Session) -> Promise<Account> {
        let request = prototype.GET("/api/me.json")
        let authenticatedRequest = applySession(session, request: request)
        return requestParsedJSON(authenticatedRequest, mapper: parseAccount)
    }
    
    func requestParsedJSON<T>(request: NSURLRequest, mapper: (JSON) -> Outcome<T, Error>) -> Promise<T> {
        return requestJSON(request).when(self, { (context, json) -> Result<T> in
//            println(json)
            if context.isErrorJSON(json) {
                return .Failure(context.parseError(json))
            } else {
                return .Deferred(context.mapJSON(json, mapper))
            }
        })
    }
    
    func requestJSON(request: NSURLRequest) -> Promise<JSON> {
        return promiseFactory.promise(request).when(self, { (context, server) -> Result<NSData> in
            return .Deferred(context.validateJSON(server))
        }).when(self, { (context, data) -> Result<JSON> in
            return .Deferred(context.parseJSON(data))
        })
    }
    
    func validateJSON(server: (response: NSURLResponse, data: NSData)) -> Promise<NSData> {
        let promise = Promise<NSData>()
        // TODO: Validate response
        promise.fulfill(server.data)
        return promise
    }
    
    func parseJSON(data: NSData) -> Promise<JSON> {
        let promise = Promise<JSON>()
        transform(input: data, transformer: defaultJSONTransformer) { [weak promise] (outcome) in
            if let strongPromise = promise {
                switch outcome {
                case .Success(let resultProducer):
                    strongPromise.fulfill(resultProducer())
                case .Failure(let reasonProducer):
                    strongPromise.reject(NSErrorWrapperError(cause: reasonProducer()))
                }
            }
        }
        return promise
    }
    
    func mapJSON<T>(input: JSON, mapper: (JSON) -> Outcome<T, Error>) -> Promise<T> {
        let promise = Promise<T>()
        
        return promise
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
    
    func parseAccount(json: JSON) -> Outcome<Account, Error> {
        let mapResult = redditFactory.redditMapper().map(json)
        
        switch mapResult {
        case .Success(let thing):
            if let account = thing() as? Account {
                return .Success(account)
            } else {
                fatalError("Expected account")
            }
        case .Failure(let error):
            return .Failure(error)
        }
    }
}
