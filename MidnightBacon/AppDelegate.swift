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
    var app: MidnightBacon!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        switch UIDevice.currentDevice().userInterfaceIdiom {
        case .Pad:
            app = MidnightBacon_iPad()
        case .Phone:
            app = MidnightBacon_iPhone()
        default:
            fatalError("Unknown device idiom")
        }
        app.start()
        return true
    }
}

extension UIApplication {
    class var services: Services {
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        return MainServices()
    }
}
