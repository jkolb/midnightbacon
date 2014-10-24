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
    var window: UIWindow!
    var storyboard: ApplicationStoryboard!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 51.0/255.0, green: 102.0/255.0, blue: 153.0/255.0, alpha: 1.0)]

        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.tintColor = UIColor(red: 51.0/255.0, green: 102.0/255.0, blue: 153.0/255.0, alpha: 1.0)

        storyboard = ApplicationStoryboard()
        storyboard.attachToWindow(window)
        window.makeKeyAndVisible()
        
        return true
    }
}
