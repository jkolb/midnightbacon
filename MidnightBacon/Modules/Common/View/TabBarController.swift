//
//  TabBarController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/29/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class TabBarController : UITabBarController {
    var shakeFactory: ShakeFactory!
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == .MotionShake {
            presentViewController(shakeFactory.shakeNavigationController(), animated: true, completion: nil)
        } else {
            super.motionEnded(motion, withEvent: event)
        }
    }
}
