//
//  AppDelegate.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/1/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

protocol Services {
    var style: Style { get }
    var gateway: Gateway { get }
    var secureStore: SecureStore { get }
    var insecureStore: InsecureStore { get }
}

class MainServices : Services {
    let style: Style
    let gateway: Gateway
    let secureStore: SecureStore
    let insecureStore: InsecureStore
    
    init() {
        style = GlobalStyle()
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPCookieAcceptPolicy = .Never
        configuration.HTTPShouldSetCookies = false
        configuration.HTTPCookieStorage = nil
        let factory = URLSessionPromiseFactory(configuration: configuration)
        gateway = Reddit(factory: factory)
        secureStore = KeychainStore()
        insecureStore = UserDefaultsStore()
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow!
    var services: Services!
    var rootController: RootController!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        services = MainServices()
        services.style.configureGlobalAppearance()
        window = services.style.createMainWindow()
        rootController = ApplicationController(services: services)
        rootController.attachToWindow(window)
        return true
    }
}

extension UIApplication {
    class var services: Services {
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        return delegate.services
    }
}
