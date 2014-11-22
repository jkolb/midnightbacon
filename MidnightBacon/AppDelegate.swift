//
//  AppDelegate.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/1/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

class MainServices : Services {
    let style: Style
    let gateway: Gateway
    let secureStore: SecureStore
    let insecureStore: InsecureStore
    
    init() {
        style = MainStyle()
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration().noCookies()
        let factory = URLSessionPromiseFactory(configuration: configuration)
        gateway = Reddit(factory: factory)
        secureStore = KeychainStore()
        insecureStore = UserDefaultsStore()
    }
}

extension NSURLSessionConfiguration {
    func noCookies() -> NSURLSessionConfiguration {
        HTTPCookieAcceptPolicy = .Never
        HTTPShouldSetCookies = false
        HTTPCookieStorage = nil
        return self
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow!
    var services: Services!
    var rootController: Controller!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        services = MainServices()
        services.style.configureGlobalAppearance()
        window = services.style.createMainWindow()
        rootController = ApplicationController(services: services)
        window.rootViewController = rootController.viewController
        window.makeKeyAndVisible()
        return true
    }
}

extension UIApplication {
    class var services: Services {
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        return delegate.services
    }
}
