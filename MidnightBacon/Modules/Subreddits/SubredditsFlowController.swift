//
//  SubredditsFlowController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/4/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

enum SubredditMenuEvent {
    case ShowSubredditLinks(title: String, path: String)
    case ShowPopularSubreddits
    case ShowNewSubreddits
}

class SubredditsFlowController : NavigationFlowController, LinksViewControllerDelegate {
    weak var factory: MainFactory!
    var commentsFlowController: CommentsFlowController!
    
    // MARK: LinksViewControllerDelegate
    
    func linksViewController(linksViewController: LinksViewController, displayLink link: Link) {
        pushViewController(factory.readLinkViewController(link))
    }
    
    func linksViewController(linksViewController: LinksViewController, showCommentsForLink link: Link) {
        commentsFlowController = factory.commentsFlowController(link)
        presentAndStartFlow(commentsFlowController)
//        pushViewController(factory.readCommentsViewController(link))
    }
    
    func linksViewController(linksViewController: LinksViewController, voteForLink link: Link, direction: VoteDirection) {
        
    }

    
    
    func openLinks(# title: String, path: String) {
        let viewController = factory.linksViewController(title: title, path: path)
        viewController.delegate = self
        pushViewController(viewController)
    }
    
    func composeUnknownSubreddit() {
        
    }
    
    func clearBackButtonTitle(viewController: UIViewController) {
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    override func viewControllerDidLoad() {
        pushViewController(menuViewController(), animated: false)
    }
    
    override func willShow(viewController: UIViewController, animated: Bool) {
        clearBackButtonTitle(viewController)
    }
    
    
    func handleSubredditMenuEvent(event: SubredditMenuEvent) {
        switch event {
        case .ShowSubredditLinks(let title, let path):
            openLinks(title: title, path: path)
        case .ShowPopularSubreddits:
            println("popular")
        case .ShowNewSubreddits:
            println("new")
        }
    }
    
    func build() -> Menu<SubredditMenuEvent> {
        let menu = Menu<SubredditMenuEvent>()
        
        menu.addGroup("Subreddits")
        menu.addNavigationItem("Front", event: .ShowSubredditLinks(title: "Front", path: "/"))
        menu.addNavigationItem("All", event: .ShowSubredditLinks(title: "All", path: "/r/all"))
        menu.addNavigationItem("Random", event: .ShowSubredditLinks(title: "Random", path: "/r/random"))
        menu.addNavigationItem("Popular", event: .ShowPopularSubreddits)
        menu.addNavigationItem("New", event: .ShowNewSubreddits)
        
        menu.addGroup("My Subreddits")
        menu.addNavigationItem("iOSProgramming", event: .ShowSubredditLinks(title: "iOSProgramming", path: "/r/iOSProgramming"))
        menu.addNavigationItem("Swift", event: .ShowSubredditLinks(title: "Swift", path: "/r/Swift"))
        menu.addNavigationItem("Programming", event: .ShowSubredditLinks(title: "Programming", path: "/r/Programming"))
        menu.addNavigationItem("movies", event: .ShowSubredditLinks(title: "movies", path: "/r/movies"))
        menu.addNavigationItem("Minecraft", event: .ShowSubredditLinks(title: "Minecraft", path: "/r/Minecraft"))
        
        menu.eventHandler = handleSubredditMenuEvent
        
        return menu
    }

    // MARK: View Controller Factory
    
    func menuViewController() -> MenuViewController {
        let viewController = MenuViewController()
        viewController.title = "Subreddits"
        viewController.menu = build()
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Compose,
            target: self,
            action: Selector("composeUnknownSubreddit")
        )
        return viewController
    }
}
