//
//  DebugFlow.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 1/12/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

class DebugFlow : ModalFlow {
    var oauthFlow: OAuthFlow!
    var debugFactory: DebugFactory!

    override func rootViewController() -> UIViewController {
        return debugFactory.shakeNavigationController()
    }
    
    func doneAction() {
        dismiss()
    }
    
    func triggerOAuth() {
        oauthFlow.present()
    }
}
