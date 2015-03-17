//
//  MainFactory.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/3/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus
import FieryCrucible

class MainFactory : DependencyFactory {
    func mainFlow() -> MainFlow {
        return shared(
            "mainFlow",
            factory: MainFlow(),
            configure: { [unowned self] (instance) in
                instance.mainFactory = self
                instance.debugFlow = self.debugFlow()
            }
        )
    }
    
    func oauthFlow() -> OAuthFlow {
        return scoped(
            "oauthFlow",
            factory: OAuthFlow(),
            configure: { instance in
                instance.styleFactory = self.sharedFactory()
                instance.sharedFactory = self.sharedFactory()
                instance.presenter = self.sharedFactory().presenter()
            }
        )
    }
    
    func debugFlow() -> DebugFlow {
        return scoped(
            "debugFlow",
            factory: DebugFlow(),
            configure: { instance in
                instance.styleFactory = self.sharedFactory()
                instance.presenter = self.sharedFactory().presenter()
                instance.oauthFlow = self.oauthFlow()
            }
        )
    }

    func sharedFactory() -> SharedFactory {
        return shared(
            "sharedFactory",
            factory: SharedFactory(),
            configure: { [unowned self] (instance) in
                instance.mainFactory = self
            }
        )
    }
    
    func subredditsFactory() -> SubredditsFactory {
        return shared(
            "subredditsFactory",
            factory: SubredditsFactory(),
            configure: { [unowned self] (instance) in
                instance.sharedFactory = self.sharedFactory()
            }
        )
    }
    
    func accountsFactory() -> AccountsFactory {
        return shared(
            "accountsFactory",
            factory: AccountsFactory(),
            configure: { [unowned self] (instance) in
                instance.sharedFactory = self.sharedFactory()
            }
        )
    }
    
    func mainWindow() -> UIWindow {
        return sharedFactory().mainWindow()
    }

//    func tabBarController() -> TabBarController {
//        return scoped(
//            "tabBarController",
//            factory: TabBarController(),
//            configure: { [unowned self] (instance) in
////                instance.delegate = self.mainFlow()
//                instance.viewControllers = [
//                    self.subredditsFactory().subredditsFlow().navigationController,
//                    self.tabNavigationController(self.messagesViewController()),
//                    self.accountsFactory().accountsFlow().navigationController,
//                    self.tabNavigationController(self.searchViewController()),
//                    self.tabNavigationController(self.configureViewController()),
//                ]
//            }
//        )
//    }
    
    func tabNavigationController(rootViewController: UIViewController) -> UINavigationController {
        return unshared(
            "tabNavigationController",
            factory: UINavigationController(rootViewController: rootViewController)
        )
    }
    
    func messagesViewController() -> UIViewController {
        return scoped(
            "messagesViewController",
            factory: UIViewController(),
            configure: { [unowned self] (instance) in
                instance.title = "Messages"
                instance.tabBarItem = UITabBarItem(title: "Messages", image: UIImage(named: "envelope"), tag: 0)
            }
        )
    }
    
    func searchViewController() -> UIViewController {
        return scoped(
            "searchViewController",
            factory: UIViewController(),
            configure: { [unowned self] (instance) in
                instance.title = "Search"
                instance.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: "search"), tag: 0)
            }
        )
    }
    
    func configureViewController() -> UIViewController {
        return scoped(
            "configureViewController",
            factory: UIViewController(),
            configure: { [unowned self] (instance) in
                instance.title = "Configure"
                instance.tabBarItem = UITabBarItem(title: "Configure", image: UIImage(named: "gears"), tag: 0)
            }
        )
    }
}
