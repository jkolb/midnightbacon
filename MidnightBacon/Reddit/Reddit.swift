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

var RedditRequestID: UInt64 = 0

class Reddit : Gateway, OAuthGateway {
    var logger: Logger!
    let promiseFactory: URLPromiseFactory
    let prototype: NSURLRequest
    let parseQueue: DispatchQueue
    
    init(factory: URLPromiseFactory, prototype: NSURLRequest, parseQueue: DispatchQueue) {
        self.promiseFactory = factory
        self.prototype = prototype
        self.parseQueue = parseQueue
    }

    func requestImage(url: NSURL) -> Promise<UIImage> {
        return requestImage(NSURLRequest(URL: url))
    }
    
    func requestImage(request: NSURLRequest) -> Promise<UIImage> {
        return performRequest(request, parser: redditImageParser)
    }
    
    func performRequest<T: APIRequest>(apiRequest: T, accessToken: OAuthAccessToken) -> Promise<T.ResponseType> {
        var request = apiRequest.build(prototype)
        request.applyAccessToken(accessToken)
        return performRequest(request) { (response) -> Outcome<T.ResponseType, Error> in
            return apiRequest.parse(response)
        }
    }
    
    func performRequest<T: APIRequest>(apiRequest: T, session sessionOrNil: Session?) -> Promise<T.ResponseType> {
        var request = apiRequest.build(prototype)
        if let session = sessionOrNil {
            request.applySession(session)
        }
        return performRequest(request) { (response) -> Outcome<T.ResponseType, Error> in
            return apiRequest.parse(response)
        }
    }
    
    func performRequest<T>(request: NSURLRequest, parser: (URLResponse) -> Outcome<T, Error>) -> Promise<T> {
        let requestID = RedditRequestID++
        logger.info("REQUEST[\(requestID)]: \(request.URL!.absoluteURL!)")
        logger.debug("HEADERS[\(requestID)]: \(asJSON(request.allHTTPHeaderFields))")
        logger.debug("BODY[\(requestID)]: \(request.HTTPBody?.UTF8String)")
        return promiseFactory.promise(request).then(self) { (context, response) -> Result<T> in
            context.logger.info("RESPONSE[\(requestID)]: \(response.metadata.URL!.absoluteURL!)")
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
