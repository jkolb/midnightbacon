//
//  MidnightBacon_iPhone.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/29/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class MidnightBacon_iPhone : NSObject, MidnightBacon {
    var services: Services!
    var sessionService: SessionService!
    var window: UIWindow!
    var tabBarController: TabBarController!
    var subredditsTabController: SubredditsTabController!
    var tab1NavigationController: UINavigationController!
    var tab2NavigationController: UINavigationController!
    var tab3NavigationController: UINavigationController!
    var tab4NavigationController: UINavigationController!
    var linksViewController: UIViewController!
    var acccountsViewController: UIViewController!
    var searchViewController: UIViewController!
    var configureViewController: UIViewController!
    
    override init() {
        super.init()
    }
    
    func start() {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        services = MainServices(window: window)
        sessionService = SessionService(services: services)
        services.style.styleWindow(window)
        setupInitialViewControllers()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    func setupInitialViewControllers() {
        subredditsTabController = SubredditsTabController(services: services)
        linksViewController = createLinksViewController()
        acccountsViewController = createAccountsViewController()
        searchViewController = createSearchViewController()
        configureViewController = createConfigureViewController()
        tab1NavigationController = createNavigationController(root: linksViewController)
        tab2NavigationController = createNavigationController(root: acccountsViewController)
        tab3NavigationController = createNavigationController(root: searchViewController)
        tab4NavigationController = createNavigationController(root: configureViewController)
        tabBarController = createTabBarController(tabs:
            [
                subredditsTabController.tabViewController,
                tab1NavigationController,
                tab2NavigationController,
                tab3NavigationController,
                tab4NavigationController
            ]
        )
    }
    
    func createLinksViewController() -> UIViewController {
        let viewController = UIViewController()
        viewController.title = "Messages"
        viewController.tabBarItem = UITabBarItem(title: "Messages", image: UIImage(named: "envelope"), tag: 0)
        return viewController
    }

    func createAccountsViewController() -> UIViewController {
        let viewController = UIViewController()
        viewController.title = "Accounts"
        viewController.tabBarItem = UITabBarItem(title: "Accounts", image: UIImage(named: "user"), tag: 0)
        return viewController
    }
    
    func createSearchViewController() -> UIViewController {
        let viewController = UIViewController()
        viewController.title = "Search"
        viewController.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: "search"), tag: 0)
        return viewController
    }
    
    func createConfigureViewController() -> UIViewController {
        let viewController = UIViewController()
        viewController.title = "Configure"
        viewController.tabBarItem = UITabBarItem(title: "Configure", image: UIImage(named: "gears"), tag: 0)
        return viewController
    }
    
    func createNavigationController(# root: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: root)
        return navigationController
    }
    
    func createTabBarController(# tabs: [UIViewController]) -> TabBarController {
        let tabBarController = TabBarController()
        tabBarController.viewControllers = tabs
        return tabBarController
    }
}
