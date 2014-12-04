//
//  MainFactory.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/3/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class MainFactory : DependencyInjection {
    func mainWindow() -> UIWindow {
        return shared(
            "mainWinow",
            factory: UIWindow(frame: UIScreen.mainScreen().bounds),
            configure: { [unowned self] (instance) in
                instance.rootViewController = self.tabBarController()
            }
        )
    }
    
    func services() -> MainServices {
        return shared(
            "services",
            factory: MainServices(window: mainWindow())
        )
    }
    
    func tabBarController() -> TabBarController {
        return scoped(
            "tabBarController",
            factory: TabBarController(),
            configure: { [unowned self] (instance) in
                instance.viewControllers = [
                    self.tabNavigationController(self.mainMenuViewController()),
                    self.tabNavigationController(self.linksViewController()),
                    self.tabNavigationController(self.accountsViewController()),
                    self.tabNavigationController(self.searchViewController()),
                    self.tabNavigationController(self.configureViewController()),
                ]
            }
        )
    }
    
    func tabNavigationController(rootViewController: UIViewController) -> UINavigationController {
        return unshared(
            UINavigationController(rootViewController: rootViewController)
        )
    }
    
    func mainMenuViewController() -> MenuViewController {
        return scoped(
            "mainMenuViewController",
            factory: MenuViewController(style: .Grouped),
            configure: { [unowned self] (instance) in
//                viewController.services = services
//                viewController.menu = buildMainMenu()
                instance.menu = Menu()
                instance.services = self.services()
                instance.title = "Subreddits"
                instance.tabBarItem = UITabBarItem(title: "Subreddits", image: UIImage(named: "list"), tag: 0)
            }
        )
    }
    
    func linksViewController() -> UIViewController {
        return scoped(
            "linksViewController",
            factory: UIViewController(),
            configure: { [unowned self] (instance) in
                instance.title = "Messages"
                instance.tabBarItem = UITabBarItem(title: "Messages", image: UIImage(named: "envelope"), tag: 0)
            }
        )
    }
    
    func accountsViewController() -> UIViewController {
        return scoped(
            "accountsViewController",
            factory: UIViewController(),
            configure: { [unowned self] (instance) in
                instance.title = "Accounts"
                instance.tabBarItem = UITabBarItem(title: "Accounts", image: UIImage(named: "user"), tag: 0)
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
