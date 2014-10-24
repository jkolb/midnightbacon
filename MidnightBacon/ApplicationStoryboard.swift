//
//  ApplicationStoryboard.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/24/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class ApplicationStoryboard {
    let style = Style()
    let navigationController = UINavigationController()
    let mainMenuViewController = MainMenuViewController(style: .Grouped)
    
    func attachToWindow(window: UIWindow) {
        setupMainNavigationBar(mainMenuViewController)
        navigationController.setViewControllers([mainMenuViewController], animated: false)
        window.rootViewController = navigationController
    }
    
    func setupMainNavigationBar(viewController: UIViewController) {
        viewController.title = NSLocalizedString("Main Menu", comment: "Main Menu Navigation Title")
        viewController.navigationItem.leftBarButtonItem = configurationBarButtonItem()
        viewController.navigationItem.rightBarButtonItem = messagesBarButtonItem()
    }
    
    func configurationBarButtonItem() -> UIBarButtonItem {
        let configurationTitle = NSLocalizedString("⚙", comment: "Configuration Bar Button Item Title")
        let button = style.barButtonItem(configurationTitle, target: self, action: "")
        button.tintColor = UIColor(red: 51.0/255.0, green: 102.0/255.0, blue: 153.0/255.0, alpha: 1.0)
        return button
    }
    
    func messagesBarButtonItem() -> UIBarButtonItem {
        let messagesTitle = NSLocalizedString("✉︎", comment: "Messages Bar Button Item Title")
        let button = style.barButtonItem(messagesTitle, target: self, action: "")
        button.tintColor = UIColor(red: 255.0/255.0, green: 69.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        return button
    }
    
    func openConfiguration() {
        let configurationViewController = ConfigurationViewController(style: .Grouped)
        configurationViewController.title = "Configuration"
        configurationViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "closeConfiguration")
        let navigationController = UINavigationController(rootViewController: configurationViewController)
        mainMenuViewController.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func closeConfiguration() {
        mainMenuViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
