//
//  SubredditsTabController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/29/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class SubredditsTabController : NSObject, TabController {
    var navigationController: UINavigationController
    var mainMenuViewController: MenuViewController
    var tabViewController: UIViewController {
        return navigationController
    }
    
    override init() {
        mainMenuViewController = MenuViewController(style: .Grouped)
        navigationController = UINavigationController(rootViewController: mainMenuViewController)
        super.init()
        mainMenuViewController.menu = buildMainMenu()
        mainMenuViewController.title = "Subreddits"
        mainMenuViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: Selector("composeUnknownSubreddit"))
        mainMenuViewController.tabBarItem = UITabBarItem(title: "Subreddits", image: UIImage(named: "list"), tag: 0)
    }
    
    func buildMainMenu() -> Menu {
        let menu = Menu()
        menu.addGroup(
            title: "Subreddits",
            items: [
                subreddit(title: "Front", path: "/"),
                subreddit(title: "All", path: "/r/all"),
                subreddit(title: "Random", path: "/r/random"),
                popularSubreddits(),
                newSubreddits(),
            ]
        )
        menu.addGroup(
            title: "My Subreddits",
            items: mySubreddits()
        )
        return menu
    }
    
    func popularSubreddits() -> Menu.Item {
        return Menu.Item(title: "Popular") { [weak self] in
            
        }
    }
    
    func newSubreddits() -> Menu.Item {
        return Menu.Item(title: "New") { [weak self] in
            
        }
    }
    
    func randomSubreddit() -> Menu.Item {
        return Menu.Item(title: "Random") { [weak self] in
            
        }
    }
    
    func mySubreddits() -> [Menu.Item] {
        var subreddits = Array<Menu.Item>()
        subreddits.append(subreddit(title: "iOSProgramming", path: "/r/iOSProgramming"))
        subreddits.append(subreddit(title: "Swift", path: "/r/Swift"))
        subreddits.append(subreddit(title: "Programming", path: "/r/Programming"))
        return subreddits
    }
    
    func subreddit(# title: String, path: String) -> Menu.Item {
        return Menu.Item(title: title) { [unowned self] in
//            self.showSubredditAction(title, path)
        }
    }
    
    func composeUnknownSubreddit() {
        
    }
}
