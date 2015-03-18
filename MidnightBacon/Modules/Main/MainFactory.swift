//
//  MainFactory.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/3/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus
import FieryCrucible
import WebKit

class MainFactory : DependencyFactory {
    func mainFlow() -> MainFlow {
        return shared(
            "mainFlow",
            factory: MainFlow(),
            configure: { instance in
                instance.factory = self
            }
        )
    }
    
    func oauthFlow() -> OAuthFlow {
        return scoped(
            "oauthFlow",
            factory: OAuthFlow(),
            configure: { instance in
                instance.factory = self
            }
        )
    }
    
    func debugFlow() -> DebugFlow {
        return scoped(
            "debugFlow",
            factory: DebugFlow(),
            configure: { instance in
                instance.factory = self
            }
        )
    }
    
    func addAccountFlow() -> AddAccountFlow {
        return scoped(
            "addAccountFlow",
            factory: AddAccountFlow(),
            configure: { instance in
                instance.factory = self
            }
        )
    }
    
    func subredditsFlow() -> SubredditsFlow {
        return shared(
            "subredditsFlow",
            factory: SubredditsFlow(),
            configure: { instance in
                instance.factory = self
            }
        )
    }
    
    func linksViewController(# title: String, path: String) -> LinksViewController {
        return scoped(
            "linksViewController",
            factory: LinksViewController(),
            configure: { instance in
                instance.style = self.style()
                instance.title = title
                instance.path = path
                instance.interactor = self.linksInteractor()
            }
        )
    }
    
    func linksInteractor() -> LinksInteractor {
        return unshared(
            "linksInteractor",
            factory: LinksInteractor(),
            configure: { [unowned self] (instance) in
                instance.gateway = self.gateway()
                instance.sessionService = self.sessionService()
                instance.thumbnailService = self.thumbnailService()
            }
        )
    }
    
    func readLinkViewController(link: Link) -> WebViewController {
        return scoped(
            "readLinkViewController",
            factory: WebViewController(),
            configure: { [unowned self] (instance) in
                instance.style = self.style()
                instance.title = "Link"
                instance.url = link.url
                instance.webViewConfiguration = self.webViewConfiguration()
            }
        )
    }
    
    func readCommentsViewController(link: Link) -> WebViewController {
        return scoped(
            "readCommentsViewController",
            factory: WebViewController(),
            configure: { [unowned self] (instance) in
                instance.style = self.style()
                instance.title = "Comments"
                instance.url = NSURL(string: "http://reddit.com/comments/\(link.id)")
                instance.webViewConfiguration = self.webViewConfiguration()
            }
        )
    }
    
    func accountsFlow() -> AccountsFlow {
        return shared(
            "accountsController",
            factory: AccountsFlow(),
            configure: { instance in
                instance.factory = self
            }
        )
    }
    
    func accountsMenuLoader(actions: AccountsActions) -> MenuLoader {
        return unshared(
            "accountsMenuLoader",
            factory: AccountsMenuLoader(),
            configure: { [unowned self] (instance) in
                instance.secureStore = self.secureStore()
                instance.insecureStore = self.insecureStore()
                instance.actions = actions
            }
        )
    }
    
    func addAccountInteractor() -> AddAccountInteractor {
        return scoped(
            "addAccountInteractor",
            factory: AddAccountInteractor(),
            configure: { [unowned self] (instance) in
                instance.gateway = self.gateway()
                instance.secureStore = self.secureStore()
            }
        )
    }
    
    func redditUserInteractor() -> RedditUserInteractor {
        return scoped(
            "redditUserInteractor",
            factory: RedditUserInteractor(),
            configure: { [unowned self] (instance) in
                instance.gateway = self.gateway()
                instance.sessionService = self.sessionService()
            }
        )
    }

    func mainWindow() -> UIWindow {
        return shared(
            "mainWinow",
            factory: UIWindow(frame: UIScreen.mainScreen().bounds)
        )
    }
    
    func style() -> Style {
        return weakShared(
            "style",
            factory: MainStyle()
        )
    }
    
    func sessionConfiguration() -> NSURLSessionConfiguration {
        return unshared(
            "sessionConfiguration",
            factory: NSURLSessionConfiguration.defaultSessionConfiguration().noCookies()
        )
    }
    
    func sessionPromiseDelegate() -> NSURLSessionPromiseDelegate {
        return unshared(
            "sessionPromiseDelegate",
            factory: SimpleURLSessionDataDelegate()
        )
    }
    
    func sessionPromiseFactory() -> URLPromiseFactory {
        return unshared(
            "sessionPromiseFactory",
            factory: NSURLSession(configuration: sessionConfiguration(), delegate: sessionPromiseDelegate(), delegateQueue: NSOperationQueue())
        )
    }
    
    func mapperFactory() -> RedditFactory {
        return unshared(
            "redditFactory",
            factory: RedditFactory()
        )
    }
    
    func gateway() -> Gateway {
        return shared(
            "gateway",
            factory: Reddit(
                factory: sessionPromiseFactory(),
                prototype: redditRequest(),
                parseQueue: parseQueue(),
                mapperFactory: mapperFactory()
            )
        )
    }
    
    func parseQueue() -> DispatchQueue {
        return weakShared(
            "parseQueue",
            factory: GCDQueue.globalPriorityDefault()
        )
    }
    
    func redditRequest() -> NSURLRequest {
        return unshared(
            "redditRequest",
            factory: NSMutableURLRequest(),
            configure: { [unowned self] (instance) in
                instance.URL = NSURL(string: "https://www.reddit.com")
                instance[.UserAgent] = "12AMBacon/0.1 by frantic_apparatus"
            }
        )
    }
    
    func secureStore() -> SecureStore {
        return shared(
            "secureStore",
            factory: KeychainStore()
        )
    }
    
    func insecureStore() -> InsecureStore {
        return shared(
            "insecureStore",
            factory: UserDefaultsStore()
        )
    }
    
    func presenter() -> Presenter {
        return shared(
            "presenter",
            factory: PresenterService(window: mainWindow())
        )
    }
    
    func authentication() -> LoginService {
        return shared(
            "authentication",
            factory: LoginService(),
            configure: { [unowned self] (instance) in
                instance.presenter = self.presenter()
            }
        )
    }
    
    func loginViewController() -> LoginViewController {
        return scoped(
            "loginViewController",
            factory: LoginViewController(style: .Grouped),
            configure: { [unowned self] (instance) in
                instance.style = self.style()
                instance.delegate = self.authentication()
                instance.title = "Login"
                instance.navigationItem.leftBarButtonItem = UIBarButtonItem.cancel(target: self.loginViewController(), action: Selector("cancel"))
                instance.navigationItem.rightBarButtonItem = UIBarButtonItem.done(target: self.loginViewController(), action: Selector("done"))
                instance.navigationItem.rightBarButtonItem?.enabled = self.loginViewController().isDoneEnabled()
            }
        )
    }
    
    func thumbnailService() -> ThumbnailService {
        return shared(
            "thumbnailService",
            factory: ThumbnailService(source: gateway(), style: style())
        )
    }
    
    func sessionService() -> SessionService {
        return shared(
            "sessionService",
            factory: SessionService(),
            configure: { [unowned self] (instance) in
                instance.insecureStore = self.insecureStore()
                instance.secureStore = self.secureStore()
                instance.gateway = self.gateway()
                instance.authentication = self.authentication()
            }
        )
    }
    
    func webViewConfiguration() -> WKWebViewConfiguration {
        return shared(
            "webViewConfiguration",
            factory: WKWebViewConfiguration(),
            configure: { [unowned self] (instance) in
                instance.processPool = WKProcessPool()
            }
        )
    }

//    func tabBarController() -> TabBarController {
//        return scoped(
//            "tabBarController",
//            factory: TabBarController(),
//            configure: { [unowned self] (instance) in
////                instance.delegate = self.mainFlow()
//                instance.viewControllers = [
//                    self.subredditsFactory().subredditsFlow().navigationController,
//                    self.tabNavigationController(self.messagesViewController()),
//                    self.accountsFactory().accountsFlow().navigationController,
//                    self.tabNavigationController(self.searchViewController()),
//                    self.tabNavigationController(self.configureViewController()),
//                ]
//            }
//        )
//    }
    
    func tabNavigationController(rootViewController: UIViewController) -> UINavigationController {
        return unshared(
            "tabNavigationController",
            factory: UINavigationController(rootViewController: rootViewController)
        )
    }
    
    func messagesViewController() -> UIViewController {
        return scoped(
            "messagesViewController",
            factory: UIViewController(),
            configure: { [unowned self] (instance) in
                instance.title = "Messages"
                instance.tabBarItem = UITabBarItem(title: "Messages", image: UIImage(named: "envelope"), tag: 0)
            }
        )
    }
    
    func searchViewController() -> UIViewController {
        return scoped(
            "searchViewController",
            factory: UIViewController(),
            configure: { [unowned self] (instance) in
                instance.title = "Search"
                instance.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: "search"), tag: 0)
            }
        )
    }
    
    func configureViewController() -> UIViewController {
        return scoped(
            "configureViewController",
            factory: UIViewController(),
            configure: { [unowned self] (instance) in
                instance.title = "Configure"
                instance.tabBarItem = UITabBarItem(title: "Configure", image: UIImage(named: "gears"), tag: 0)
            }
        )
    }
}
