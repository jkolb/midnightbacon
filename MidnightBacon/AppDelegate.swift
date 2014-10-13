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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let linksViewController = LinksViewController()
        linksViewController.title = "All"
        let navigationController = UINavigationController(rootViewController: linksViewController)
//        navigationController?.navigationBar.translucent = true
//        navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        navigationController?.navigationBar.barStyle = .Black
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        return true
    }
}

extension UIView {
    func exerciseAmbiguityInLayoutRepeatedly(recursive: Bool) {
        if hasAmbiguousLayout() {
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "exerciseAmbiguityInLayout", userInfo: nil, repeats: true)
        }
        if recursive {
            for subview in subviews {
                subview.exerciseAmbiguityInLayoutRepeatedly(true)
            }
        }
    }
}
