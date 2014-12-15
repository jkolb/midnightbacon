//
//  Outcome.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/14/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

enum Outcome<Result, Reason> {
    case Success(@autoclosure () -> Result)
    case Failure(@autoclosure () -> Reason)
}
