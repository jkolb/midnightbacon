//
//  SubredditsFlowController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/4/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class SubredditsFlowController : NavigationFlowController, LinksViewControllerDelegate {
    typealias Action = SubredditAction
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
    
    
    func handleSubredditAction(action: SubredditAction) {
        switch action {
        case .ShowSubredditLinks(let title, let path):
            openLinks(title: title, path: path)
        case .ShowPopularSubreddits:
            println("popular")
        case .ShowNewSubreddits:
            println("new")
        }
    }
    
    func build() -> Menu<SubredditAction> {
        let menu = Menu<SubredditAction>()
        
        menu.addGroup("Subreddits")
        menu.addItem("Front", action: .ShowSubredditLinks(title: "Front", path: "/"))
        menu.addItem("All", action: .ShowSubredditLinks(title: "All", path: "/r/all"))
        menu.addItem("Random", action: .ShowSubredditLinks(title: "Random", path: "/r/random"))
        menu.addItem("Popular", action: .ShowPopularSubreddits)
        menu.addItem("New", action: .ShowNewSubreddits)
        
        menu.addGroup("My Subreddits")
        menu.addItem("iOSProgramming", action: .ShowSubredditLinks(title: "iOSProgramming", path: "/r/iOSProgramming"))
        menu.addItem("Swift", action: .ShowSubredditLinks(title: "Swift", path: "/r/Swift"))
        menu.addItem("Programming", action: .ShowSubredditLinks(title: "Programming", path: "/r/Programming"))
        menu.addItem("movies", action: .ShowSubredditLinks(title: "movies", path: "/r/movies"))
        menu.addItem("Minecraft", action: .ShowSubredditLinks(title: "Minecraft", path: "/r/Minecraft"))
        
        menu.actionHandler = handleSubredditAction
        
        return menu
    }

    // MARK: View Controller Factory
    
    func menuViewController() -> SubredditsMenuViewController {
        let viewController = SubredditsMenuViewController()
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
