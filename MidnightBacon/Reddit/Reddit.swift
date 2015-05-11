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
import Common
import Reddit

var RedditRequestID: UInt64 = 0

/* Servers are busy, try again
2015-05-10 21:02:24.983 INFO MidnightBacon[2055] Reddit.swift:60 STATUS[2]: 503
2015-05-10 21:02:24.983 DEBUG MidnightBacon[2055] Reddit.swift:61 HEADERS[2]: {
"cf-ray" : "1e4a4cf1a3551183-DFW",
"Server" : "cloudflare-nginx",
"Date" : "Mon, 11 May 2015 02:02:24 GMT",
"Content-Type" : "text\/html; charset=UTF-8",
"Set-Cookie" : "__cfduid=dd27c1842f9aefb09e5628dd99435d97c1431309734; expires=Tue, 10-May-16 02:02:14 GMT; path=\/; domain=.reddit.com; HttpOnly"
}
2015-05-10 21:02:24.983 DEBUG MidnightBacon[2055] Reddit.swift:62 JSON[2]: <!doctype html><html><title>Ow! -- reddit.com</title><style>body{text-align:center;position:absolute;top:50%;margin:0;margin-top:-275px;width:100%}h2,h3{color:#555;font:bold 200%/100px sans-serif;margin:0}h3,p{color:#777;font:normal 150% sans-serif}p{font-size: 100%;font-style:italic;margin-top:2em;}</style><img src=//www.redditstatic.com/trouble-afoot.jpg alt=""><h2>all of our servers are busy right now</h2><h3>please try again in a minute</h3><p>(error code: 503)
 */

class Reddit : Gateway {
    var logger: Logger!
    var userAgent: String?
    let promiseFactory: NSURLSession
    let parseQueue: DispatchQueue
    
    init(factory: NSURLSession, parseQueue: DispatchQueue) {
        self.promiseFactory = factory
        self.parseQueue = parseQueue
    }

    func requestImage(url: NSURL) -> Promise<UIImage> {
        return requestImage(NSURLRequest(URL: url))
    }
    
    func requestImage(request: NSURLRequest) -> Promise<UIImage> {
        return performRequest(request, parser: redditImageParser)
    }
    
    func performRequest<T: APIRequest>(apiRequest: T) -> Promise<T.ResponseType> {
        return actuallyPerformRequest(apiRequest, accessToken: nil)
    }
    
    func performRequest<T: APIRequest>(apiRequest: T, accessToken: AuthorizationToken) -> Promise<T.ResponseType> {
        return actuallyPerformRequest(apiRequest, accessToken: accessToken)
    }

    func actuallyPerformRequest<T: APIRequest>(apiRequest: T, accessToken: AuthorizationToken?) -> Promise<T.ResponseType> {
        let request = apiRequest.build()
        request[.UserAgent] = userAgent
        request.applyAccessToken(accessToken)
        return performRequest(request) { (response) -> Outcome<T.ResponseType, Error> in
            return apiRequest.parse(response)
        }
    }
    
    func performRequest<T>(request: NSURLRequest, parser: (URLResponse) -> Outcome<T, Error>) -> Promise<T> {
        let requestID = RedditRequestID++
        logger.info("REQUEST[\(requestID)]: \(request.URL!.absoluteURL!)")
        logger.debug("HEADERS[\(requestID)]: \(asJSON(request.allHTTPHeaderFields))")
        logger.debug("BODY[\(requestID)]: \(request.HTTPBody?.UTF8String)")
        return promiseFactory.mb_promise(request).then(self) { (context, response) -> Result<T> in
            context.logger.info("RESPONSE[\(requestID)]: \(response.metadata.URL!.absoluteURL!)")
            context.logger.info("STATUS[\(requestID)]: \(response.metadata.asHTTP.statusCode)")
            context.logger.debug("HEADERS[\(requestID)]: \(asJSON(response.metadata.asHTTP.allHeaderFields))")
            context.logger.debug {
                if let json: String = response.data.UTF8String {
                    return "JSON[\(requestID)]: \(json)"
                } else {
                    return "DATA[\(requestID)]: \(response.data)"
                }
            }
            return Result(transform(on: context.parseQueue, input: response, transformer: parser))
        }
    }
}
