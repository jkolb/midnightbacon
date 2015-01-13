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
    
    func oauth() -> OAuth {
        let baseURL = NSURL(string: "https://www.reddit.com/")!
        let clientID = "fnOncggIlO7nwA"
        let redirectURI = NSURL(string: "midnightbacon://oauth_redirect")!
        let duration = TokenDuration.Permanent
        let scope: [OAuthScope] = [.Read, .PrivateMessages, .Vote]
        return shared(
            "oauth",
            factory: OAuth(baseURL: baseURL, clientID: clientID, redirectURI: redirectURI, duration: duration, scope: scope)
        )
    }
}
