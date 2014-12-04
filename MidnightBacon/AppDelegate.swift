//
//  AppDelegate.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/1/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var factory: MainFactory!
    var app: MidnightBacon = MidnightBaconUserInterfaceIdiomInstance()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        factory = MainFactory()
        factory.mainWindow().makeKeyAndVisible()
//        
//        app.start()
        return true
    }
}
