//
//  OAuthFactory.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 2/25/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import FieryCrucible

class OAuthFactory : DependencyFactory {
    var sharedFactory: SharedFactory!
    
    func oauthFlow() -> OAuthFlow {
        return shared(
            "oauthFlow",
            factory: OAuthFlow(),
            configure: { [unowned self] (instance) in
                instance.styleFactory = self.sharedFactory
                instance.sharedFactory = self.sharedFactory
                instance.presenter = self.sharedFactory.presenter()
            }
        )
    }
}
