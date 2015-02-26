//
//  FlowFactory.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 2/25/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import FieryCrucible

class FlowFactory : DependencyFactory {
    var mainFactory: MainFactory!
    var sharedFactory: SharedFactory!
    
    func mainFlow() -> MainFlow {
        return shared(
            "mainFlow",
            factory: MainFlow()
        )
    }
}
