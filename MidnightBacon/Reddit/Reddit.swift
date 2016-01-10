//
//  Reddit.swift
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
    let userAgent: String
    let promiseFactory: NSURLSession
    let parseQueue: DispatchQueue
    
    init(userAgent: String, factory: NSURLSession, parseQueue: DispatchQueue) {
        self.userAgent = userAgent
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
        return performRequest(request) { (response) throws -> T.ResponseType in
            return try apiRequest.parse(response)
        }
    }
    
    func performRequest<T>(request: NSURLRequest, parser: (URLResponse) throws -> T) -> Promise<T> {
        let requestID = RedditRequestID++
        logger.info("REQUEST[\(requestID)]: \(request.URL!.absoluteURL)")
        logger.debug("HEADERS[\(requestID)]: \(asJSON(request.allHTTPHeaderFields))")
        logger.debug("BODY[\(requestID)]: \(request.HTTPBody?.UTF8String)")
        return promiseFactory.mb_promise(request).thenWithContext(self) { (context, response) -> Promise<T> in
            context.logger.info("RESPONSE[\(requestID)]: \(response.metadata.URL!.absoluteURL)")
            context.logger.info("STATUS[\(requestID)]: \(response.metadata.HTTP.statusCode)")
            context.logger.debug("HEADERS[\(requestID)]: \(asJSON(response.metadata.HTTP.allHeaderFields))")
            context.logger.debug {
                if let json: String = response.data.UTF8String {
                    return "JSON[\(requestID)]: \(json)"
                } else {
                    return "DATA[\(requestID)]: \(response.data)"
                }
            }
            return context.parseResponse(response, parser: parser)
        }
    }
    
    func parseResponse<T>(response: URLResponse, parser: (URLResponse) throws -> T) -> Promise<T> {
        return Promise<T> { (fulfill, reject, isCancelled) -> Void in
            parseQueue.dispatch {
                do {
                    fulfill(try parser(response))
                }
                catch {
                    reject(error)
                }
            }
        }
    }
}
