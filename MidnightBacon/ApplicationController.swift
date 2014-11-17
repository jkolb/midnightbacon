//
//  ApplicationController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/24/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

@objc class ApplicationController {
    let style = GlobalStyle()
    let reddit = Reddit()
    let redditSession: RedditSession!
    let navigationController = UINavigationController()
    let mainMenuViewController = MainMenuViewController(style: .Grouped)
    var scale = UIScreen.mainScreen().scale
    var subreddits = NSCache()
    let secureStore = KeychainStore()
    let insecureStore = UserDefaultsStore()
    lazy var authenticationController: AuthenticationController = {
        AuthenticationController(presenter: self.navigationController)
    }()
    
    init() {
        self.redditSession = RedditSession(
            reddit: reddit,
            credentialFactory: authenticate,
            secureStore: secureStore,
            insecureStore: insecureStore
        )
    }
    
    func authenticate() -> Promise<NSURLCredential> {
        return authenticationController.authenticate()
    }
    
    func attachToWindow(window: UIWindow) {
        mainMenuViewController.menu = MenuBuilder(controller: self).mainMenu()
        setupMainNavigationBar(mainMenuViewController)
        navigationController.setViewControllers([mainMenuViewController], animated: false)
        window.rootViewController = navigationController
    }
    
    func setupMainNavigationBar(viewController: UIViewController) {
        viewController.title = NSLocalizedString("Main Menu", comment: "Main Menu Navigation Title")
        viewController.navigationItem.leftBarButtonItem = configurationBarButtonItem()
        
        if let username = insecureStore.lastAuthenticatedUsername {
            viewController.navigationItem.rightBarButtonItem = messagesBarButtonItem()
        }
    }
    
    func configurationBarButtonItem() -> UIBarButtonItem {
        let configurationTitle = NSLocalizedString("⚙", comment: "Configuration Bar Button Item Title")
        let button = style.barButtonItem(configurationTitle, target: self, action: Selector("openConfiguration"))
        button.tintColor = UIColor(red: 51.0/255.0, green: 102.0/255.0, blue: 153.0/255.0, alpha: 1.0)
        return button
    }
    
    func messagesBarButtonItem() -> UIBarButtonItem {
        let messagesTitle = NSLocalizedString("✉︎", comment: "Messages Bar Button Item Title")
        let button = style.barButtonItem(messagesTitle, target: self, action: Selector("openConfiguration"))
        button.tintColor = UIColor(red: 255.0/255.0, green: 69.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        return button
    }
    
    func openConfiguration() {
        let configurationViewController = ConfigurationViewController(style: .Grouped)
        configurationViewController.secureStore = secureStore
        configurationViewController.insecureStore = insecureStore
        configurationViewController.title = "Configuration"
        configurationViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "closeConfiguration")
        let navigationController = UINavigationController(rootViewController: configurationViewController)
        mainMenuViewController.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func closeConfiguration() {
        mainMenuViewController.dismissViewControllerAnimated(true, completion: nil)
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
}
