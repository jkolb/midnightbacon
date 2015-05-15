//
//  MainStyle.swift
//  MidnightBacon
//
// Copyright (c) 2015 Justin Kolb - http://franticapparatus.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
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
