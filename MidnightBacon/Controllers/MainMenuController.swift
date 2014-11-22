//
//  MainMenuController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class MainMenuController {
    var onOpenConfiguration: (() -> ())?
    var onOpenMessages: (() -> ())?
    var onOpenSubreddit: ((String, String) -> ())?
    
    init() {
    }
    
    func rootViewController() -> UIViewController {
        let viewController = MenuViewController(style: .Grouped)
        viewController.menu = mainMenu()
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
            action: Selector("openConfigurationAction")
        )
    }
    
    func messagesBarButtonItem(# hasMessages: Bool) -> UIBarButtonItem {
        return UIApplication.services.style.barButtonItem(
            title: NSLocalizedString("✉︎", comment: "Messages Bar Button Item Title"),
            tintColor: hasMessages ? UIApplication.services.style.redditOrangeRedColor : UIApplication.services.style.redditUITextColor,
            target: self,
            action: Selector("openConfigurationAction")
        )
    }
    
    @objc func openConfigurationAction() {
        if let openConfigurationHandler = onOpenConfiguration {
            openConfigurationHandler()
        }
    }
    
    func mainMenu() -> Menu {
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
        
        if let username = UIApplication.services.insecureStore.lastAuthenticatedUsername {
            menu.addGroup(
                title: username,
                items: [
                    userOverview(),
                    userSubreddits(),
                    userComments(),
                    userSubmitted(),
                    userGilded(),
                    userLiked(),
                    userDisliked(),
                    userHidden(),
                    userSaved(),
                ]
            )
        }
        
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
        return Menu.Item(title: title) { [weak self] in
            //            controller?.openLinks(title: title, path: path)
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
