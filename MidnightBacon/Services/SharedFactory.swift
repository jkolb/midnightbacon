//
//  SharedFactory.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/4/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

class SharedFactory : DependencyInjection {
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
    
    func services() -> MainServices {
        return shared(
            "services",
            factory: MainServices(window: mainWindow())
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
            factory: URLSessionPromiseFactory(configuration: self.sessionConfiguration())
        )
    }
    
    func gateway() -> Gateway {
        return shared(
            "gateway",
            factory: Reddit(factory: self.sessionPromiseFactory())
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
            factory: PresenterService(window: self.mainWindow())
        )
    }
    
    func authentication() -> AuthenticationService {
        return shared(
            "authentication",
            factory: LoginService(presenter: self.presenter())
        )
    }
}
