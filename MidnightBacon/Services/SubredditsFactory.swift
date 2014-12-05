//
//  SubredditsFactory.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/4/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class SubredditsFactory : DependencyInjection {
    var sharedFactory: SharedFactory!
    
    func subredditsController() -> SubredditsController {
        return shared(
            "subredditsController",
            factory: SubredditsController(),
            configure: { [unowned self] (instance) in
                instance.subredditsFactory = self
                instance.navigationController = self.tabNavigationController()
            }
        )
    }
    
    func tabNavigationController() -> UINavigationController {
        return scoped(
            "tabNavigationController",
            factory: UINavigationController(rootViewController: subredditsMenuViewController()),
            configure: { [unowned self] (instance) in
                instance.delegate = self.subredditsController()
            }
        )
    }
    
    func subredditsMenuViewController() -> MenuViewController {
        return scoped(
            "subredditsMenuViewController",
            factory: MenuViewController(style: .Grouped),
            configure: { [unowned self] (instance) in
                instance.menu = self.subredditsMenuBuilder().build()
                instance.style = self.sharedFactory.style()
                instance.title = "Subreddits"
                instance.tabBarItem = UITabBarItem(title: "Subreddits", image: UIImage(named: "list"), tag: 0)
                instance.navigationItem.rightBarButtonItem = UIBarButtonItem(
                    barButtonSystemItem: .Compose,
                    target: self.subredditsController(),
                    action: Selector("composeUnknownSubreddit")
                )
            }
        )
    }

    func subredditsMenuBuilder() -> SubredditsMenuBuilder {
        return unshared(
            "subredditsMenuBuilder",
            factory: SubredditsMenuBuilder(),
            configure: { [unowned self] (instance) in
                instance.actionController = self.subredditsController()
            }
        )
    }
    
    func linksViewController(# title: String, path: String) -> LinksViewController {
        return scoped(
            "linksViewController",
            factory: LinksViewController(),
            configure: { [unowned self] (instance) in
                instance.title = title
                instance.path = path
                instance.style = self.sharedFactory.style()
                instance.interactor = self.linksInteractor()
                instance.actionController = self.subredditsController()
            }
        )
    }
    
    func linksInteractor() -> LinksInteractor {
        return unshared(
            "linksInteractor",
            factory: LinksInteractor(),
            configure: { [unowned self] (instance) in
                instance.gateway = self.sharedFactory.gateway()
                instance.sessionService = self.sharedFactory.sessionService()
                instance.thumbnailService = self.sharedFactory.thumbnailService()
            }
        )
    }
}
