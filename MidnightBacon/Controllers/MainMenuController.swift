//
//  MainMenuController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class MainMenuController : Controller {
    var showSubredditAction: ((String, String) -> ())!
    
    lazy var menuViewController: MenuViewController = { [unowned self] in
        let viewController = MenuViewController(style: .Grouped)
        viewController.menu = self.buildMainMenu()
        viewController.title = NSLocalizedString("Main Menu", comment: "Main Menu Navigation Title")
        return viewController
    }()
    
    var viewController: UIViewController {
        return menuViewController
    }

    init() {
    }
    
    func buildMainMenu() -> Menu {
        let menu = Menu()
        menu.addGroup(
            title: "Subreddits",
            items: [
                subreddit(title: "Front", path: "/"),
                subreddit(title: "All", path: "/r/all"),
                popularSubreddits(),
                newSubreddits(),
                subreddit(title: "Random", path: "/r/random"),
                searchSubreddits(),
            ]
        )
        menu.addGroup(
            title: "My Subreddits",
            items: mySubreddits()
        )
        menu.addGroup(
            title: "Submit",
            items: [
                submitNewLink(),
                submitNewTextPost(),
            ]
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
    
    func searchSubreddits() -> Menu.Item {
        return Menu.Item(title: "Search") { [weak self] in
            
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
            self.showSubredditAction(title, path)
        }
    }
    
    func submitNewLink() -> Menu.Item {
        return Menu.Item(title: "New Link") { [weak self] in
            
        }
    }
    
    func submitNewTextPost() -> Menu.Item {
        return Menu.Item(title: "New Text Post") { [weak self] in
            
        }
    }
    
    func userOverview() -> Menu.Item {
        return Menu.Item(title: "Overview") { [weak self] in
            
        }
    }
    
    func userSubreddits() -> Menu.Item {
        return Menu.Item(title: "Subreddits") { [weak self] in
            
        }
    }
    
    func userComments() -> Menu.Item {
        return Menu.Item(title: "Comments") { [weak self] in
            
        }
    }
    
    func userSubmitted() -> Menu.Item {
        return Menu.Item(title: "Submitted") { [weak self] in
            
        }
    }
    
    func userGilded() -> Menu.Item {
        return Menu.Item(title: "Gilded") { [weak self] in
            
        }
    }
    
    func userLiked() -> Menu.Item {
        return Menu.Item(title: "Liked") { [weak self] in
            
        }
    }
    
    func userDisliked() -> Menu.Item {
        return Menu.Item(title: "Disliked") { [weak self] in
            
        }
    }
    
    func userHidden() -> Menu.Item {
        return Menu.Item(title: "Hidden") { [weak self] in
            
        }
    }
    
    func userSaved() -> Menu.Item {
        return Menu.Item(title: "Saved") { [weak self] in
            
        }
    }
}
