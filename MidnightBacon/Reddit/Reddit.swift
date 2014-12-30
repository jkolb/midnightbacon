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
    let promiseFactory: URLPromiseFactory
    let prototype: NSURLRequest
    let parseQueue: DispatchQueue
    let mapperFactory: RedditFactory
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
    
    init(factory: URLPromiseFactory, prototype: NSURLRequest, parseQueue: DispatchQueue, mapperFactory: RedditFactory) {
        self.promiseFactory = factory
        self.prototype = prototype
        self.parseQueue = parseQueue
        self.mapperFactory = mapperFactory
    }

    func requestImage(url: NSURL) -> Promise<UIImage> {
        return requestImage(NSURLRequest(URL: url))
    }
    
    func requestImage(request: NSURLRequest) -> Promise<UIImage> {
        return performRequest(request, parser: redditImageParser)
    }

    func parseImage(server: (response: NSURLResponse, data: NSData)) -> Promise<UIImage> {
        let promise = Promise<UIImage>()
        return promise
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
        return performRequest(authenticatedRequest) { (response) -> Outcome<Bool, Error> in
            return redditJSONMapper(response) { (json) -> Outcome<Bool, Error> in
                println(json)
                return .Success(true)
            }
        }
    }
    
    func apiMe(# session: Session) -> Promise<Account> {
        let request = prototype.GET("/api/me.json")
        let authenticatedRequest = applySession(session, request: request)
        let mapperFactory = self.mapperFactory
        return performRequest(authenticatedRequest) { (response) -> Outcome<Account, Error> in
            let mapResult = redditJSONMapper(response, mapperFactory.redditMapper().map)
            
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
    
    func performRequest<T: APIRequest>(apiRequest: T, session sessionOrNil: Session?) -> Promise<T.ResponseType> {
        var request = apiRequest.build(prototype)
        if let session = sessionOrNil {
            request = applySession(session, request: request)
        }
        let mapperFactory = self.mapperFactory
        return promiseFactory.promise(request).when(self) { (context, response) -> Result<T.ResponseType> in
            return .Deferred(transform(on: context.parseQueue, input: response) { (response) -> Outcome<T.ResponseType, Error> in
                return apiRequest.parse(response, mapperFactory: mapperFactory)
            })
        }
    }
    
    func performRequest<T>(request: NSURLRequest, parser: (URLResponse) -> Outcome<T, Error>) -> Promise<T> {
        return promiseFactory.promise(request).when(self) { (context, response) -> Result<T> in
            return .Deferred(transform(on: context.parseQueue, input: response, transformer: parser))
        }
    }
    
    func applySession(session: Session, request: NSMutableURLRequest) -> NSMutableURLRequest {
        if countElements(session.cookie) > 0 {
            if let cookie = session.cookie.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
                request.setValue("reddit_session=" + cookie, forHTTPHeaderField: "Cookie")
            }
        }
        
        if countElements(session.modhash) > 0 {
            request.setValue(session.modhash, forHTTPHeaderField: "X-Modhash")
        }
        
        return request
    }
}
