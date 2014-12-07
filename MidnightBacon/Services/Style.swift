//
//  Style.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/23/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

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
    
    var linkTitleFont: UIFont! { get set }
    var linkCommentsFont: UIFont! { get set }
    var linkDetailsFont: UIFont! { get set }

    func linkCellFontsDidChange()

    func applyTo(viewController: TableViewController)
    func applyToTextOnlyLinkCell(cell: TextOnlyLinkCell)
    func applyToThumbnailLinkCell(cell: ThumbnailLinkCell)
}
