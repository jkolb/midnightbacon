//
//  Promise+Outcome.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/22/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus
import ModestProposal

func transform<T, U>(on queue: DispatchQueue, # input: T, # transformer: (T) -> Outcome<U, Error>) -> Promise<U> {
    return Promise<U> { (fulfill, reject, isCancelled) in
        queue.dispatch {
            switch transformer(input) {
            case .Success(let result):
                fulfill(result.unwrap)
            case .Failure(let reason):
                reject(reason.unwrap)
            }
        }
    }
}
