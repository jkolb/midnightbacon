//
//  SharedFactory.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/4/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus
import FieryCrucible

class SharedFactory : DependencyFactory {
    var mainFactory: MainFactory!

    func mainWindow() -> UIWindow {
        return shared(
            "mainWinow",
            factory: UIWindow(frame: UIScreen.mainScreen().bounds),
            configure: { [unowned self] (instance) in
                instance.rootViewController = self.mainFactory.tabBarController()
            }
        )
    }
    
    func style() -> Style {
        return shared(
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
    
    func sessionPromiseFactory() -> URLSessionPromiseFactory {
        return unshared(
            "sessionPromiseFactory",
            factory: URLSessionPromiseFactory(configuration: sessionConfiguration())
        )
    }
    
    func redditFactory() -> RedditFactory {
        return unshared(
            "redditFactory",
            factory: RedditFactory()
        )
    }
    
    func gateway() -> Gateway {
        return shared(
            "gateway",
            factory: Reddit(factory: sessionPromiseFactory()),
            configure: { [unowned self] (instance) in
                instance.redditFactory = self.redditFactory()
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
                instance.sharedFactory = self
            }
        )
    }
    
    func loginViewController() -> LoginViewController {
        return scoped(
            "loginViewController",
            factory: LoginViewController(style: .Grouped),
            configure: { [unowned self] (instance) in
                instance.style = self.style()
                instance.onCancel = self.authentication().onCancel
                instance.onDone = self.authentication().onDone
                instance.onDoneEnabled = self.authentication().onDoneEnabled
                instance.title = "Login"
                instance.navigationItem.leftBarButtonItem = self.loginCancelBarButtonItem()
                instance.navigationItem.rightBarButtonItem = self.loginDoneBarButtonItem()
            }
        )
    }
    
    func loginCancelBarButtonItem() -> UIBarButtonItem {
        return scoped(
            "loginCancelBarButtonItem",
            factory: UIBarButtonItem.cancel(target: loginViewController(), action: Selector("cancel"))
        )
    }
    
    func loginDoneBarButtonItem() -> UIBarButtonItem {
        return scoped(
            "loginDoneBarButtonItem",
            factory: UIBarButtonItem.done(target: loginViewController(), action: Selector("done")),
            configure: { [unowned self] (instance) in
                instance.enabled = self.loginViewController().isDoneEnabled()
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
}
