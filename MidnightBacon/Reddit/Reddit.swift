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
    
    func performRequest<T: APIRequest>(apiRequest: T, session sessionOrNil: Session?) -> Promise<T.ResponseType> {
        var request = apiRequest.build(prototype)
        if let session = sessionOrNil {
            request.applySession(session)
        }
        let mapperFactory = self.mapperFactory
        return performRequest(request) { (response) -> Outcome<T.ResponseType, Error> in
            return apiRequest.parse(response, mapperFactory: mapperFactory)
        }
    }
    
    func performRequest<T>(request: NSURLRequest, parser: (URLResponse) -> Outcome<T, Error>) -> Promise<T> {
        return promiseFactory.promise(request).when(self) { (context, response) -> Result<T> in
            return Result(transform(on: context.parseQueue, input: response, transformer: parser))
        }
    }
}
