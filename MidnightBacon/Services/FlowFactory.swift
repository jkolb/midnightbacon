//
//  FlowFactory.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 2/25/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import FieryCrucible

class FlowFactory : DependencyFactory {
    func mainFlow() -> MainFlow {
        return shared(
            "mainFlow",
            factory: MainFlow()
        )
    }
    
    func oauthFlow() -> OAuthFlow {
        return shared(
            "oauthFlow",
            factory: OAuthFlow()
        )
    }
}
