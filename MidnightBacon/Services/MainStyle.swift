//
//  MainStyle.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

struct GlobalStyle : Style {
    let lightColor = UIColor(white: 0.96, alpha: 1.0)
    let darkColor = UIColor(white: 0.04, alpha: 1.0)
    let mediumColor = UIColor(white: 0.5, alpha: 1.0)
    let translucentDarkColor = UIColor(white: 0.04, alpha: 0.2)
    let redditOrangeColor = UIColor(0xff5700)
    let redditOrangeRedColor = UIColor(0xff4500)
    let redditUpvoteColor = UIColor(0xff8b60)
    let redditNeutralColor = UIColor(0xc6c6c6)
    let redditDownvoteColor = UIColor(0x9494ff)
    let redditLightBackgroundColor = UIColor(0xeff7ff)
    let redditHeaderColor = UIColor(0xcee3f8)
    let redditUITextColor = UIColor(0x336699)
    
    func configureGlobalAppearance() {
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: redditUITextColor]
    }
    
    func createMainWindow() -> UIWindow {
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.tintColor = redditUITextColor
        return window
    }
    
    func barButtonItem(title: String, target: AnyObject?, action: Selector) -> UIBarButtonItem {
        let button = UIBarButtonItem(title: title, style: .Plain, target: target, action: action)
        let font = UIFont(name: "Helvetica", size: 24.0)
        let attributes = NSMutableDictionary()
        attributes[NSFontAttributeName] = font
        button.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
        return button
    }
    
    func applyTo(viewController: TableViewController) {
        viewController.tableView.backgroundColor = lightColor
        viewController.tableView.layoutMargins = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        viewController.tableView.separatorColor = mediumColor
        viewController.tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
    }
}
