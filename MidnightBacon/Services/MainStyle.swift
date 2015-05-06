//
//  MainStyle.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import Common

final class MainStyle : Style {
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
    let scale = UIScreen.mainScreen().scale
    let cellInsets = UIEdgeInsets(top: 16.0, left: 8.0, bottom: 16.0, right: 8.0)

    var linkTitleFont: UIFont!
    var linkCommentsFont: UIFont!
    var linkDetailsFont: UIFont!
    
    func configureGlobalAppearance() {
        UIWindow.appearance().tintColor = redditUITextColor
        UITabBar.appearance().tintColor = redditUITextColor
        UINavigationBar.appearance().tintColor = redditUITextColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: redditUITextColor]
        UITextField.appearance().textColor = redditUITextColor
    }
    
    func linkCellFontsDidChange() {
        linkTitleFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        linkCommentsFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        linkDetailsFont = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
    }
}
