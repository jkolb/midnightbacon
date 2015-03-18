//
//  MainFlow.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 2/25/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

class MainFlow : TabFlow {
    weak var factory: MainFactory!
    var debugFlow: DebugFlow!
    var subredditsFlow: SubredditsFlow!
    var accountsFlow: AccountsFlow!
    
    override func viewControllerDidLoad() {
        tabBarController.viewControllers = [
            startSubredditsFlow(),
            startAccountsFlow(),
        ]
    }
    
    func startSubredditsFlow() -> UIViewController {
        subredditsFlow = factory.subredditsFlow()
        
        let viewController = subredditsFlow.start()
        viewController.title = "Subreddits"
        viewController.tabBarItem = UITabBarItem(title: "Subreddits", image: UIImage(named: "list"), tag: 0)
        return viewController
    }
    
    func startAccountsFlow() -> UIViewController {
        accountsFlow = factory.accountsFlow()
        
        let viewController = accountsFlow.start()
        viewController.title = "Accounts"
        viewController.tabBarItem = UITabBarItem(title: "Accounts", image: UIImage(named: "user"), tag: 0)
        return viewController
    }
    
    func tabBarControllerDidDetectShake(tabBarController: TabBarController) {
        if debugFlow.canStart {
//            debugFlow.start(mainFactory.sharedFactory().presenter())
        }
    }
}
