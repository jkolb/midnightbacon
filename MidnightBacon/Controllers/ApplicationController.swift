//
//  ApplicationController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/24/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

class ApplicationController : Controller {
    let redditSession: RedditController!
    var scale = UIScreen.mainScreen().scale
    var subreddits = NSCache()
    var authenticationController: AuthenticationController!
    var addUserPromise: Promise<Bool>?
    var lastAuthenticatedUsername: String? {
        return UIApplication.services.insecureStore.lastAuthenticatedUsername
    }
    var configurationController: ConfigurationController!
    
    init(services: Services) {
        self.redditSession = RedditController(services: services, credentialFactory: authenticate)
    }
    
    func authenticate() -> Promise<NSURLCredential> {
        return authenticationController.authenticate()
    }
    
    lazy var mainMenuController: MainMenuController = { [unowned self] in
        let controller = MainMenuController()
        controller.configureAction = self.configureAction()
        return controller
    }()
    lazy var navigationController: UINavigationController = { [unowned self] in
        return UINavigationController(rootViewController: self.mainMenuController.viewController)
    }()
    
    var viewController: UIViewController {
        return navigationController
    }

    func configureAction() -> TargetAction {
        return TargetAction { [unowned self] in
            self.configurationController = ConfigurationController()
            self.configurationController.doneAction = self.configurationDoneAction()
            self.presentController(self.configurationController)
        }
    }
    
    func configurationDoneAction() -> TargetAction {
        return TargetAction { [unowned self] in
            self.dismissController(animated: true) {
                self.configurationController = nil
            }
        }
    }
    
    func linksController(path: String, refresh: Bool) -> LinksController {
        if let controller = subreddits.objectForKey(path) as? LinksController {
            if refresh {
                let refreshController = LinksController(reddit: redditSession, path: path)
                subreddits.setObject(refreshController, forKey: path)
                return refreshController
            } else {
                return controller
            }
        } else {
            let controller = LinksController(reddit: redditSession, path: path)
            subreddits.setObject(controller, forKey: path)
            return controller
        }
    }

    func openLinks(# title: String, path: String) {
        let linksViewController = LinksViewController()
        linksViewController.linksController = linksController(path, refresh: false)
        linksViewController.scale = scale
        linksViewController.applicationController = self
        linksViewController.title = title
        linksViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort", style: .Plain, target: linksViewController, action: Selector("performSort"))
        pushViewController(linksViewController)
    }
    
    func displayLink(link: Link) {
        let web = WebViewController()
        web.title = "Link"
        web.url = link.url
        pushViewController(web)
    }
    
    func showComments(link: Link) {
        let web = WebViewController()
        web.title = "Comments"
        web.url = NSURL(string: "http://reddit.com\(link.permalink)")
        pushViewController(web)
    }
    
//    func addUser(reloadable: Reloadable) {
//        addUserPromise = redditSession.addUser().when(self, { [weak reloadable] (context, success) -> () in
//            if let strongReloadable = reloadable {
//                strongReloadable.reload()
//            }
//        }).finally(self, { (context) in
//            context.addUserPromise = nil
//        })
//    }
    
    func pushViewController(viewController: UIViewController, animated: Bool = true) {
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func presentController(controller: Controller, animated: Bool = true, completion: (() -> ())? = nil) {
        var presentingViewController: UIViewController = navigationController
        
        while presentingViewController.presentedViewController != nil {
            presentingViewController = presentingViewController.presentedViewController!
        }
        
        let containerController = UINavigationController(rootViewController: controller.viewController)
        presentingViewController.presentViewController(containerController, animated: animated, completion: completion)
    }
    
    func dismissController(animated: Bool = true, completion: (() -> ())? = nil) {
        var presentingViewController: UIViewController = navigationController
        
        while presentingViewController.presentedViewController != nil {
            presentingViewController = presentingViewController.presentedViewController!
        }
        
        presentingViewController.presentingViewController!.dismissViewControllerAnimated(true, completion: completion)
    }
}
