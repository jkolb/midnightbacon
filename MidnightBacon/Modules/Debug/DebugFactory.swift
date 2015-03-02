//
//  DebugFactory.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 1/9/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit
import FieryCrucible

class DebugFactory : DependencyFactory {
    var mainFactory: MainFactory!
    var styleFactory: StyleFactory!
    
    func debugFlow() -> DebugFlow {
        return shared(
            "debugFlow",
            factory: DebugFlow(),
            configure: { [unowned self] (instance) in
                instance.styleFactory = self.mainFactory.sharedFactory()
                instance.presenter = self.mainFactory.sharedFactory().presenter()
                instance.oauthFlow = self.mainFactory.oauthFactory().oauthFlow()
            }
        )
    }
}
