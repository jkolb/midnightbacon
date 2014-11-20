//
//  AsyncParse.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

enum ParseResult<T> {
    case Success(@autoclosure () -> T)
    case Failure(Error)
}

func asyncParse<Input, Output>(on queue: DispatchQueue, # input: Input, # parser: (Input) -> ParseResult<Output>) -> Promise<Output> {
    let promise = Promise<Output>()
    queue.dispatch { [weak promise] in
        if let strongPromise = promise {
            switch parser(input) {
            case .Success(let value):
                strongPromise.fulfill(value())
            case .Failure(let error):
                strongPromise.reject(error)
            }
        }
    }
    return promise
}
