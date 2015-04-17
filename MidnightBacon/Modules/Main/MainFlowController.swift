//
//  MainFlowController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 2/25/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

class MainFlowController : TabFlowController, TabBarControllerDelegate, DebugFlowControllerDelegate {
    weak var factory: MainFactory!
    var debugFlowController: DebugFlowController!
    var subredditsFlowController: SubredditsFlowController!
    var accountsFlowController: AccountsFlowController!
    var tabController: TabBarController!
    
    override func loadViewController() {
        tabController = TabBarController()
        tabBarController = tabController // Fix this!
        viewController = tabController
    }
    
    override func viewControllerDidLoad() {
        tabBarController.delegate = self
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
    
    
    // MARK: - TabBarControllerDelegate
    
    func tabBarControllerDidDetectShake(tabBarController: TabBarController) {
        if debugFlowController == nil {
            debugFlowController = DebugFlowController()
            debugFlowController.factory = factory
            debugFlowController.delegate = self
        }
        
        if debugFlowController.canStart {
            presentAndStartFlow(debugFlowController, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - DebugFlowControllerDelegate
    
    func debugFlowControllerDidCancel(debugFlowController: DebugFlowController) {
        debugFlowController.stopAnimated(true) { [weak self] in
            self?.debugFlowController = nil
        }
    }
}
