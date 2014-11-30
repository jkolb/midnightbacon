//
//  MainServices.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/23/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

class MainServices : Services {
    let style: Style
    let gateway: Gateway
    let secureStore: SecureStore
    let insecureStore: InsecureStore
    let presenter: Presenter
    let authentication: AuthenticationService
    
    init(window: UIWindow) {
        style = MainStyle()
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration().noCookies()
        let factory = URLSessionPromiseFactory(configuration: configuration)
        gateway = Reddit(factory: factory)
        secureStore = KeychainStore()
        insecureStore = UserDefaultsStore()
        presenter = PresenterService(window: window)
        authentication = LoginService(presenter: presenter)
    }
}
