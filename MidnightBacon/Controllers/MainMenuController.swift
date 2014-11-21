//
//  MainMenuController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class MainMenuController {
    func rootViewController() -> UIViewController {
        let viewController = MenuViewController(style: .Grouped)
        viewController.menu = MenuBuilder().mainMenu()
        viewController.title = NSLocalizedString("Main Menu", comment: "Main Menu Navigation Title")
        viewController.navigationItem.leftBarButtonItem = configurationBarButtonItem()
        return viewController
    }
    
    func updateMessagesBarButtonItem(viewController: UIViewController, hasMessages: Bool, animated: Bool) {
        viewController.navigationItem.setRightBarButtonItem(messagesBarButtonItem(hasMessages: hasMessages), animated: animated)
    }
    
    func configurationBarButtonItem() -> UIBarButtonItem {
        return UIApplication.services.style.barButtonItem(
            title: NSLocalizedString("⚙", comment: "Configuration Bar Button Item Title"),
            tintColor: UIApplication.services.style.redditUITextColor,
            target: self,
            action: Selector("openConfiguration")
        )
    }
    
    func messagesBarButtonItem(# hasMessages: Bool) -> UIBarButtonItem {
        return UIApplication.services.style.barButtonItem(
            title: NSLocalizedString("✉︎", comment: "Messages Bar Button Item Title"),
            tintColor: hasMessages ? UIApplication.services.style.redditOrangeRedColor : UIApplication.services.style.redditUITextColor,
            target: self,
            action: Selector("openConfiguration")
        )
    }
}
