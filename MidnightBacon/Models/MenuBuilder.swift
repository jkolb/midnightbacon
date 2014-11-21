//
//  MenuFactory.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class MenuBuilder {
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
    
    func accountMenu(usernames: [String]) -> Menu {
        let menu = Menu()
        
        if let username = UIApplication.services.insecureStore.lastAuthenticatedUsername {
            menu.addGroup(
                title: username,
                items: [
                    logout(username),
                    preferences(username),
                ]
            )
        }

        var accountItems = Array<Menu.Item>()
        
        for username in usernames {
            accountItems.append(displayUser(username))
        }
        
//        accountItems.append(addAccount(reloadable))
        accountItems.append(registerAccount())
        
        menu.addGroup(
            title: "Accounts",
            items: accountItems
        )
        
        return menu
    }
    
    func logout(username: String) -> Menu.Item {
        return Menu.Item(title: "Logout") { [weak self] in
            
        }
    }
    
    func preferences(username: String) -> Menu.Item {
        return Menu.Item(title: "Preferences") { [weak self] in
            
        }
    }
    
    func displayUser(username: String) -> Menu.Item {
        return Menu.Item(title: username) { [weak self] in
            
        }
    }
    
//    func addAccount(reloadable: Reloadable) -> Menu.Item {
//        return Menu.Item(title: "Add Existing Account") { [weak self, weak reloadable] in
//            if let strongSelf = self {
//                if let strongReloadable = reloadable {
//                    strongSelf.controller.addUser(strongReloadable)
//                }
//            }
//        }
//    }
    
    func registerAccount() -> Menu.Item {
        return Menu.Item(title: "Register New Account") { [weak self] in
            
        }
    }
}
