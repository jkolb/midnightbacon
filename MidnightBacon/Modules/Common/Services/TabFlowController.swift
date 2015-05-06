//
//  TabFlowController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 3/1/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

public class TabFlowController : FlowController {
    public var tabBarController: UITabBarController!
    
    deinit {
        if tabBarController != nil {
            tabBarController.delegate = nil
        }
    }

    public override func loadViewController() {
        tabBarController = UITabBarController()
        viewController = tabBarController
    }
    
    public override func viewControllerWillUnload() {
        tabBarController.delegate = nil
    }

    public override func viewControllerDidUnload() {
        tabBarController = nil
    }
}
