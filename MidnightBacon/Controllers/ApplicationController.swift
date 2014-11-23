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
    var subreddits = NSCache()
    var authenticationController: AuthenticationController!
    var addUserPromise: Promise<Bool>?
    var lastAuthenticatedUsername: String? {
        return UIApplication.services.insecureStore.lastAuthenticatedUsername
    }
    var configurationController: ConfigurationController!
    
    init(services: Services) {
    }
    
    func authenticate() -> Promise<NSURLCredential> {
        return authenticationController.authenticate()
    }
    
    lazy var mainMenuController: MainMenuController = { [unowned self] in
        let controller = MainMenuController()
        controller.configureAction = self.configureAction()
        controller.showSubredditAction = self.openLinks
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
    
    func openLinks(# title: String, path: String) {
        pushController(linksController(path, refresh: false))
    }
    
    func linksInteractor() -> LinksInteractor {
        return LinksInteractor(
            redditGateway: UIApplication.services.gateway,
            sessionService: SessionService(services: UIApplication.services, credentialFactory: authenticate),
            thumbnailService: ThumbnailService(source: UIApplication.services.gateway)
        )
    }
    
    func linksController(path: String, refresh: Bool) -> LinksController {
        if let controller = subreddits.objectForKey(path) as? LinksController {
            if refresh {
                let refreshController = LinksController(interactor: linksInteractor(), path: path)
                subreddits.setObject(refreshController, forKey: path)
                return refreshController
            } else {
                return controller
            }
        } else {
            let controller = LinksController(interactor: linksInteractor(), path: path)
            subreddits.setObject(controller, forKey: path)
            return controller
        }
    }
    
    func displayLink(link: Link) {
        let web = WebViewController()
        web.title = "Link"
        web.url = link.url
//        pushViewController(web)
    }
    
    func showComments(link: Link) {
        let web = WebViewController()
        web.title = "Comments"
        web.url = NSURL(string: "http://reddit.com\(link.permalink)")
//        pushViewController(web)
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
    
    func pushController(controller: Controller, animated: Bool = true) {
        navigationController.pushViewController(controller.viewController, animated: animated)
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
