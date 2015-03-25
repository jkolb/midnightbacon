//
//  MainFlowController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 2/25/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

class MainFlowController : TabFlowController {
    weak var factory: MainFactory!
    var debugFlowController: DebugFlowController!
    var subredditsFlowController: SubredditsFlowController!
    var accountsFlowController: AccountsFlowController!
    
    override func viewControllerDidLoad() {
        tabBarController.viewControllers = [
            startSubredditsFlow(),
            startAccountsFlow(),
        ]
    }
    
    func startSubredditsFlow() -> UIViewController {
        subredditsFlowController = factory.subredditsFlowController()
        
        let viewController = subredditsFlowController.start()
        viewController.title = "Subreddits"
        viewController.tabBarItem = UITabBarItem(title: "Subreddits", image: UIImage(named: "list"), tag: 0)
        return viewController
    }
    
    func startAccountsFlow() -> UIViewController {
        accountsFlowController = factory.accountsFlowController()
        
        let viewController = accountsFlowController.start()
        viewController.title = "Accounts"
        viewController.tabBarItem = UITabBarItem(title: "Accounts", image: UIImage(named: "user"), tag: 0)
        return viewController
    }
    
    func tabBarControllerDidDetectShake(tabBarController: TabBarController) {
        if debugFlowController.canStart {
//            debugFlow.start(mainFactory.sharedFactory().presenter())
        }
    }
}
