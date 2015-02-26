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
    
    func shakeFactory() -> ShakeFactory {
        return shared(
            "shakeFactory",
            factory: ShakeFactory(),
            configure: { [unowned self] (instance) in
                instance.mainFactory = self
            }
        )
    }
    
    func flowFactory() -> FlowFactory {
        return shared(
            "flowFactory",
            factory: FlowFactory(),
            configure: { [unowned self] (instance) in
                instance.sharedFactory = self.sharedFactory()
            }
        )
    }
    
    func oauthFactory() -> OAuthFactory {
        return shared(
            "oauthFactory",
            factory: OAuthFactory(),
            configure: { [unowned self] (instance) in
                instance.sharedFactory = self.sharedFactory()
            }
        )
    }
    
    func mainWindow() -> UIWindow {
        return sharedFactory().mainWindow()
    }

    func tabBarController() -> TabBarController {
        return scoped(
            "tabBarController",
            factory: TabBarController(),
            configure: { [unowned self] (instance) in
                instance.shakeFactory = self.shakeFactory()
                instance.viewControllers = [
                    self.subredditsFactory().subredditsController().navigationController,
                    self.tabNavigationController(self.messagesViewController()),
                    self.accountsFactory().accountsController().navigationController,
                    self.tabNavigationController(self.searchViewController()),
                    self.tabNavigationController(self.configureViewController()),
                ]
            }
        )
    }
    
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
