//
//  ApplicationController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/24/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

protocol RootController {
    func attachToWindow(window: UIWindow)
    func presentViewController(viewController: UIViewController, animated: Bool, completion: (() -> ())?)
    func dismissViewControllerAnimated(animated: Bool, completion: (() -> ())?)
}

@objc class ApplicationController : RootController, ViewControllerPresenter {
    let redditSession: RedditSession!
    let navigationController = UINavigationController()
    let mainMenuViewController = MenuViewController(style: .Grouped)
    var scale = UIScreen.mainScreen().scale
    var subreddits = NSCache()
    lazy var authenticationController: AuthenticationController = {
        AuthenticationController(presenter: self)
    }()
    var addUserPromise: Promise<Bool>?
    var lastAuthenticatedUsername: String? {
        return UIApplication.services.insecureStore.lastAuthenticatedUsername
    }

    init(services: Services) {
        self.redditSession = RedditSession(services: services, credentialFactory: authenticate)
    }
    
    func authenticate() -> Promise<NSURLCredential> {
        return authenticationController.authenticate()
    }
    
    func attachToWindow(window: UIWindow) {
        mainMenuViewController.menu = MenuBuilder(controller: self).mainMenu()
        setupMainNavigationBar(mainMenuViewController)
        navigationController.setViewControllers([mainMenuViewController], animated: false)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    func setupMainNavigationBar(viewController: UIViewController) {
        viewController.title = NSLocalizedString("Main Menu", comment: "Main Menu Navigation Title")
        viewController.navigationItem.leftBarButtonItem = configurationBarButtonItem()
        
        if let username = lastAuthenticatedUsername {
            viewController.navigationItem.rightBarButtonItem = messagesBarButtonItem()
        }
    }
    
    func createBarButtonItem(# title: String, color: UIColor, action: Selector) -> UIBarButtonItem {
        let style = UIApplication.services.style
        let button = style.barButtonItem(title, target: self, action: action)
        button.tintColor = color
        return button
    }
    
    func configurationBarButtonItem() -> UIBarButtonItem {
        let title = NSLocalizedString("⚙", comment: "Configuration Bar Button Item Title")
        let color = UIApplication.services.style.redditUITextColor
        let action = Selector("openConfiguration")
        return createBarButtonItem(title: title, color: color, action: action)
    }
    
    func messagesBarButtonItem() -> UIBarButtonItem {
        let title = NSLocalizedString("✉︎", comment: "Messages Bar Button Item Title")
        let color = UIApplication.services.style.redditOrangeRedColor
        let action = Selector("openConfiguration")
        return createBarButtonItem(title: title, color: color, action: action)
    }
    
    func openConfiguration() {
        let configurationViewController = MenuViewController(style: .Grouped)
        configurationViewController.title = "Configuration"
        configurationViewController.promiseFactory = { [weak self] in
            if let strongSelf = self {
                let secureStore = UIApplication.services.secureStore
                return secureStore.findUsernames().when(strongSelf, { (strongSelf2, usernames) -> Result<Menu> in
                    let menuBuilder = MenuBuilder(controller: strongSelf2)
                    return .Success(menuBuilder.accountMenu(usernames))
                })
            } else {
                let promise = Promise<Menu>()
                promise.reject(Error(message: "ApplicationController deinit"))
                return promise
            }
        }
        configurationViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "closeConfiguration")
        let navigationController = UINavigationController(rootViewController: configurationViewController)
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func closeConfiguration() {
        dismissViewControllerAnimated(true, completion: nil)
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
        navigationController.pushViewController(linksViewController, animated: true)
    }
    
    func displayLink(link: Link) {
        let web = WebViewController()
        web.title = "Link"
        web.url = link.url
        navigationController.pushViewController(web, animated: true)
    }
    
    func showComments(link: Link) {
        let web = WebViewController()
        web.title = "Comments"
        web.url = NSURL(string: "http://reddit.com\(link.permalink)")
        navigationController.pushViewController(web, animated: true)
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
    
    // MARK: ViewControllerPresenter
    
    func presentViewController(viewController: UIViewController, animated: Bool, completion: (() -> ())?) {
        var presentingViewController: UIViewController = navigationController
        
        while presentingViewController.presentedViewController != nil {
            presentingViewController = presentingViewController.presentedViewController!
        }
        
        presentingViewController.presentViewController(viewController, animated: animated, completion: completion)
    }
    
    func dismissViewControllerAnimated(animated: Bool, completion: (() -> ())?) {
        var presentingViewController: UIViewController = navigationController
        
        while presentingViewController.presentedViewController != nil {
            presentingViewController = presentingViewController.presentedViewController!
        }
        
        presentingViewController.presentingViewController!.dismissViewControllerAnimated(true, completion: completion)
    }
}
