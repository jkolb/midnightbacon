//
//  MainFactory.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/3/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

class MainFactory : DependencyInjection {
    func sharedFactory() -> SharedFactory {
        return shared(
            "sharedFactory",
            factory: SharedFactory(),
            configure: { [unowned self] (instance) in
                instance.mainFactory = self
            }
        )
    }
    
    func mainWindow() -> UIWindow {
        return sharedFactory().mainWindow()
    }
    
    func services() -> MainServices {
        return sharedFactory().services()
    }
  
    func style() -> Style {
        return sharedFactory().style()
    }
    
    func gateway() -> Gateway {
        return sharedFactory().gateway()
    }
    
    func secureStore() -> SecureStore {
        return sharedFactory().secureStore()
    }

    func insecureStore() -> InsecureStore {
        return sharedFactory().insecureStore()
    }
    
    func presenter() -> Presenter {
        return sharedFactory().presenter()
    }
    
    func authentication() -> AuthenticationService {
        return sharedFactory().authentication()
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
            "tabNavigationController",
            factory: UINavigationController(rootViewController: rootViewController)
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
                instance.style = self.style()
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
