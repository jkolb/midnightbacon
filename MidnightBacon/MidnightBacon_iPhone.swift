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
    var window: UIWindow!
    var tabBarController: UITabBarController!
    var tab0NavigationController: UINavigationController!
    var tab1NavigationController: UINavigationController!
    var mainMenuViewController: UIViewController!
    var linksViewController: UIViewController!
    
    override init() {
        super.init()
    }
    
    func start() {
        services = MainServices()
        services.style.configureGlobalAppearance()
        setupInitialViewControllers()
        window = services.style.createMainWindow()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    func setupInitialViewControllers() {
        mainMenuViewController = createMainMenuViewController()
        linksViewController = createLinksViewController()
        tab0NavigationController = createNavigationController(root: mainMenuViewController)
        tab1NavigationController = createNavigationController(root: linksViewController)
        tabBarController = createTabBarController(tabs: [tab0NavigationController, tab1NavigationController])
    }
    
    func createMainMenuViewController() -> UIViewController {
        let viewController = UITableViewController()
        viewController.title = "Menu"
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.configure(self, action: Selector("configureAction"))
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem.messages(self, action: Selector("messagesAction"))
        return viewController
    }
    
    func createLinksViewController() -> UIViewController {
        let viewController = UIViewController()
        viewController.title = "Front"
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem.sort(self, action: Selector("sortAction"))
        return viewController
    }
    
    func createNavigationController(# root: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: root)
        return navigationController
    }
    
    func createTabBarController(# tabs: [UIViewController]) -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = tabs
        return tabBarController
    }
    
    func configureAction() {
    }
    
    func sortAction() {
    }
    
    func messagesAction() {
    }
}
