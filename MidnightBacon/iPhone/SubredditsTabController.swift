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
        
        subreddits.append(subreddit(title: "mildlyinteresting", path: "/r/mildlyinteresting"))
        subreddits.append(subreddit(title: "EarthPorn", path: "/r/EarthPorn"))
        subreddits.append(subreddit(title: "videos", path: "/r/videos"))
        subreddits.append(subreddit(title: "todayilearned", path: "/r/todayilearned"))
        subreddits.append(subreddit(title: "gadgets", path: "/r/gadgets"))
        subreddits.append(subreddit(title: "books", path: "/r/books"))
        subreddits.append(subreddit(title: "Music", path: "/r/Music"))
        subreddits.append(subreddit(title: "Documentaries", path: "/r/Documentaries"))
        subreddits.append(subreddit(title: "TowXChromosomes", path: "/r/TowXChromosomes"))
        subreddits.append(subreddit(title: "InternetIsBeautiful", path: "/r/InternetIsBeautiful"))
        subreddits.append(subreddit(title: "tifu", path: "/r/tifu"))
        subreddits.append(subreddit(title: "funny", path: "/r/funny"))
        subreddits.append(subreddit(title: "OldSchoolCool", path: "/r/OldSchoolCool"))
        subreddits.append(subreddit(title: "movies", path: "/r/movies"))
        subreddits.append(subreddit(title: "IAmA", path: "/r/IAmA"))
        subreddits.append(subreddit(title: "Showerthoughts", path: "/r/Showerthoughts"))
        subreddits.append(subreddit(title: "sports", path: "/r/sports"))
        subreddits.append(subreddit(title: "blog", path: "/r/blog"))
        subreddits.append(subreddit(title: "food", path: "/r/food"))
        subreddits.append(subreddit(title: "nottheonion", path: "/r/nottheonion"))
        subreddits.append(subreddit(title: "announcements", path: "/r/announcements"))
        subreddits.append(subreddit(title: "explainlikeimfive", path: "/r/explainlikeimfive"))
        subreddits.append(subreddit(title: "gaming", path: "/r/gaming"))
        subreddits.append(subreddit(title: "gifs", path: "/r/gifs"))
        subreddits.append(subreddit(title: "aww", path: "/r/aww"))
        subreddits.append(subreddit(title: "askscience", path: "/r/askscience"))
        subreddits.append(subreddit(title: "Futurology", path: "/r/Futurology"))
        subreddits.append(subreddit(title: "philosophy", path: "/r/philosophy"))
        subreddits.append(subreddit(title: "UpliftingNews", path: "/r/UpliftingNews"))
        subreddits.append(subreddit(title: "worldnews", path: "/r/worldnews"))
        subreddits.append(subreddit(title: "LifeProTips", path: "/r/LifeProTips"))
        subreddits.append(subreddit(title: "Fitness", path: "/r/Fitness"))
        subreddits.append(subreddit(title: "news", path: "/r/news"))
        subreddits.append(subreddit(title: "photoshopbattles", path: "/r/photoshopbattles"))
        subreddits.append(subreddit(title: "television", path: "/r/television"))
        subreddits.append(subreddit(title: "WritingPrompts", path: "/r/WritingPrompts"))
        subreddits.append(subreddit(title: "Art", path: "/r/Art"))
        subreddits.append(subreddit(title: "Jokes", path: "/r/Jokes"))
        subreddits.append(subreddit(title: "science", path: "/r/science"))
        subreddits.append(subreddit(title: "dataisbeautiful", path: "/r/dataisbeautiful"))
        subreddits.append(subreddit(title: "space", path: "/r/space"))
        subreddits.append(subreddit(title: "personalfinance", path: "/r/personalfinance"))
        subreddits.append(subreddit(title: "creepy", path: "/r/creepy"))
        subreddits.append(subreddit(title: "pics", path: "/r/pics"))
        subreddits.append(subreddit(title: "nosleep", path: "/r/nosleep"))
        subreddits.append(subreddit(title: "AskReddit", path: "/r/AskReddit"))
        subreddits.append(subreddit(title: "listentothis", path: "/r/listentothis"))
        subreddits.append(subreddit(title: "history", path: "/r/history"))
        subreddits.append(subreddit(title: "GetMotivated", path: "/r/GetMotivated"))
        subreddits.append(subreddit(title: "DIY", path: "/r/DIY"))

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
