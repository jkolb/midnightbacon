//
//  Promise+Outcome.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/22/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus
import ModestProposal

extension Promise {
    func resolve(outcome: Outcome<T, Error>) {
        switch outcome {
        case .Success(let resultProducer):
            fulfill(resultProducer())
        case .Failure(let reasonProducer):
            reject(reasonProducer())
        }
    }
}

func transform<T, U>(on queue: DispatchQueue, # input: T, # transformer: (T) -> Outcome<U, Error>) -> Promise<U> {
    let promise = Promise<U>()
    queue.dispatch { [weak promise] in
        if let strongPromise = promise {
            strongPromise.resolve(transformer(input))
        }
    }
    return promise
}
