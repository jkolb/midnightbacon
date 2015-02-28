//
//  DebugFlow.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 1/12/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

class DebugFlow : NSObject {
    var presenter: Presenter!
    var oauthFlow: OAuthFlow!
    var debugFactory: DebugFactory!

    func present() {
        presenter.presentViewController(debugFactory.shakeNavigationController(), animated: true, completion: nil)
    }
    
    func doneAction() {
        presenter.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func triggerAction() {
        oauthFlow.present()
    }
}
