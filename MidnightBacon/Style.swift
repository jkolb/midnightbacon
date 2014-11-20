//
//  Style.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/23/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(_ red: UInt8, _ green: UInt8, _ blue: UInt8) {
        let r = CGFloat(red) / 255.0
        let g = CGFloat(green) / 255.0
        let b = CGFloat(blue) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    convenience init(_ rgb: UInt32) {
        let r = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x0000FF00) >> 08) / 255.0
        let b = CGFloat((rgb & 0x000000FF) >> 00) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

protocol Style {
    var lightColor: UIColor { get }
    var darkColor: UIColor { get }
    var mediumColor: UIColor { get }
    var translucentDarkColor: UIColor { get }
    var redditOrangeColor: UIColor { get }
    var redditOrangeRedColor: UIColor { get }
    var redditUpvoteColor: UIColor { get }
    var redditNeutralColor: UIColor { get }
    var redditDownvoteColor: UIColor { get }
    var redditLightBackgroundColor: UIColor { get }
    var redditHeaderColor: UIColor { get }
    var redditUITextColor: UIColor { get }
    
    func configureGlobalAppearance()
    func createMainWindow() -> UIWindow
    func barButtonItem(title: String, target: AnyObject?, action: Selector) -> UIBarButtonItem
}

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
}
