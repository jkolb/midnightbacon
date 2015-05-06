//
//  TabFlowController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 3/1/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

class TabFlowController : FlowController {
    var tabBarController: UITabBarController!
    
    deinit {
        if tabBarController != nil {
            tabBarController.delegate = nil
        }
    }

    override func loadViewController() {
        tabBarController = UITabBarController()
        viewController = tabBarController
    }
    
    override func viewControllerWillUnload() {
        tabBarController.delegate = nil
    }

    override func viewControllerDidUnload() {
        tabBarController = nil
    }
}
