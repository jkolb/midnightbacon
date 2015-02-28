//
//  TabBarController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/29/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

protocol TabBarControllerDelegate : UITabBarControllerDelegate {
    func tabBarControllerDidDetectShake(tabBarController: TabBarController)
}

class TabBarController : UITabBarController {
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == .MotionShake {
            if let delegate = self.delegate as? TabBarControllerDelegate {
                delegate.tabBarControllerDidDetectShake(self)
            } else {
                super.motionEnded(motion, withEvent: event)
            }
        } else {
            super.motionEnded(motion, withEvent: event)
        }
    }
}
