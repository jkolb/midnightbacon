//
//  SubredditsController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/4/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

protocol SubredditsActionController {
    func openLinks(# title: String, path: String)
}

protocol LinksActionController {
    func displayLink(link: Link)
    func showComments(link: Link)
}

class SubredditsController : NSObject, UINavigationControllerDelegate, SubredditsActionController, LinksActionController {
    var subredditsFactory: SubredditsFactory!
    var navigationController: UINavigationController!
    
    func openLinks(# title: String, path: String) {
        show(subredditsFactory.linksViewController(title: title, path: path))
    }

    func displayLink(link: Link) {
        let readLinkController = ReadLinkController()
        readLinkController.link = link
        show(readLinkController.viewController)
    }
    
    func showComments(link: Link) {
        let readCommentsController = ReadCommentsController()
        readCommentsController.link = link
        show(readCommentsController.viewController)
    }
    
    func composeUnknownSubreddit() {
        
    }
    
    func show(viewController: UIViewController, animated: Bool = true) {
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func clearBackButtonTitle(viewController: UIViewController) {
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    // MARK: - UINavigationControllerDelegate
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        clearBackButtonTitle(viewController)
    }
}
