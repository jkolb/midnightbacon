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
    var mainMenuViewController: MainMenuViewController!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 51.0/255.0, green: 102.0/255.0, blue: 153.0/255.0, alpha: 1.0)]
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.tintColor = UIColor(red: 51.0/255.0, green: 102.0/255.0, blue: 153.0/255.0, alpha: 1.0)
        
        mainMenuViewController = MainMenuViewController(style: .Grouped)
        mainMenuViewController.title = "Main Menu"
        let button = UIBarButtonItem(title: "⚙", style: .Plain, target: self, action: "openConfiguration")
        let font = UIFont(name: "Helvetica", size: 24.0)
        let attributes = NSMutableDictionary()
        attributes[NSFontAttributeName] = font
        button.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
        button.tintColor = UIColor(red: 51.0/255.0, green: 102.0/255.0, blue: 153.0/255.0, alpha: 1.0)
        mainMenuViewController?.navigationItem.leftBarButtonItem = button
        let button1 = UIBarButtonItem(title: "✉︎", style: .Plain, target: self, action: "openConfiguration")
        let font1 = UIFont(name: "Helvetica", size: 24.0)
        let attributes1 = NSMutableDictionary()
        attributes1[NSFontAttributeName] = font
        button1.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
        button1.tintColor = UIColor(red: 255.0/255.0, green: 69.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        mainMenuViewController?.navigationItem.rightBarButtonItem = button1

        let navigationController = UINavigationController(rootViewController: mainMenuViewController!)
//        navigationController?.navigationBar.barStyle = .Black
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        return true
    }
    
    func openConfiguration() {
        let configurationViewController = ConfigurationViewController(style: .Grouped)
        configurationViewController.title = "Configuration"
        configurationViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "closeConfiguration")
        let navigationController = UINavigationController(rootViewController: configurationViewController)
        mainMenuViewController.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func closeConfiguration() {
        mainMenuViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
