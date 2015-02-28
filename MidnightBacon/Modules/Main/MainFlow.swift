//
//  MainFlow.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 2/25/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation

class MainFlow : NSObject, TabBarControllerDelegate {
    var mainFactory: MainFactory!
    var debugFlow: DebugFlow!
    
    func present() {
        mainFactory.mainWindow().makeKeyAndVisible()
    }
    
    func tabBarControllerDidDetectShake(tabBarController: TabBarController) {
        if debugFlow.canPresent {
            debugFlow.present()
        }
    }
}
