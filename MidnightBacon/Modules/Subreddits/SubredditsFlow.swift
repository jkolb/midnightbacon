//
//  SubredditsFlow.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/4/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

protocol SubredditsActionController {
    func openLinks(# title: String, path: String)
}

class SubredditsFlow : NavigationFlow, LinksViewControllerDelegate, SubredditsActionController {
    var styleFactory: StyleFactory!
    var subredditsFactory: SubredditsFactory!
    
    
    // MARK: LinksViewControllerDelegate
    
    func linksViewController(linksViewController: LinksViewController, displayLink link: Link) {
        push(subredditsFactory.readLinkViewController(link))
    }
    
    func linksViewController(linksViewController: LinksViewController, showCommentsForLink link: Link) {
        push(subredditsFactory.readCommentsViewController(link))
    }
    
    func linksViewController(linksViewController: LinksViewController, voteForLink link: Link, direction: VoteDirection) {
        
    }

    
    
    func openLinks(# title: String, path: String) {
        let viewController = subredditsFactory.linksViewController(title: title, path: path)
        viewController.delegate = self
        push(viewController)
    }
    
    func composeUnknownSubreddit() {
        
    }
    
    func clearBackButtonTitle(viewController: UIViewController) {
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    override func viewControllerDidLoad() {
        push(menuViewController(), animated: false)
    }
    
    override func willShow(viewController: UIViewController, animated: Bool) {
        clearBackButtonTitle(viewController)
    }
    
    
    // MARK: View Controller Factory
    
    func menuViewController() -> MenuViewController {
        let menuBuilder = SubredditsMenuBuilder()
        menuBuilder.actionController = self
        
        let viewController = MenuViewController(style: .Grouped)
        viewController.style = styleFactory.style()
        viewController.title = "Subreddits"
        viewController.menu = menuBuilder.build()
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Compose,
            target: self,
            action: Selector("composeUnknownSubreddit")
        )
        return viewController
    }
}
