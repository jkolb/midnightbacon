//
//  DebugController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 1/12/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

class DebugController : NSObject {
    var mainWindow: UIWindow!
    var oauth: OAuth!
    
    func doneAction() {
        mainWindow.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func triggerAction() {
        oauth.requestAccess()
    }
}
