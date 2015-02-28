//
//  MainFlow.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 2/25/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation

class MainFlow : NSObject, TabBarControllerDelegate {
    var debugFlow: DebugFlow!
    
    func tabBarControllerDidDetectShake(tabBarController: TabBarController) {
        debugFlow.present()
    }
}
