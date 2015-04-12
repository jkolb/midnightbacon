//
//  MainStyle.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

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
    let commentCellInsets = UIEdgeInsets(top: 16.0, left: 8.0, bottom: 16.0, right: 8.0)

    var linkTitleFont: UIFont!
    var linkCommentsFont: UIFont!
    var linkDetailsFont: UIFont!

    init() {
        self.dynamicType.configureGlobalAppearance(self)
    }
    
    class func configureGlobalAppearance(style: Style) {
        UIWindow.appearance().tintColor = style.redditUITextColor
        UITabBar.appearance().tintColor = style.redditUITextColor
        UINavigationBar.appearance().tintColor = style.redditUITextColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: style.redditUITextColor]
        UITextField.appearance().textColor = style.redditUITextColor
        UITableViewCell.appearance().separatorInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
        UITableViewCell.appearance().layoutMargins = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        UITableViewCell.appearance().preservesSuperviewLayoutMargins = false
    }
    
    func applyTo(viewController: TableViewController) {
        viewController.tableView.backgroundColor = lightColor
        viewController.tableView.layoutMargins = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        viewController.tableView.separatorColor = mediumColor
        viewController.tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
    }
    
    func applyTo(cell: TextOnlyLinkCell) {
        applyToLinkCell(cell)
    }
    
    func applyTo(cell: ThumbnailLinkCell) {
        cell.thumbnailImageView.layer.masksToBounds = true
        cell.thumbnailImageView.contentMode = .ScaleAspectFit
        cell.thumbnailImageView.layer.cornerRadius = 4.0
        cell.thumbnailImageView.layer.borderWidth = 1.0 / scale
        cell.thumbnailImageView.layer.borderColor = darkColor.colorWithAlphaComponent(0.2).CGColor
        
        applyToLinkCell(cell)
    }
    
    func linkCellFontsDidChange() {
        linkTitleFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        linkCommentsFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        linkDetailsFont = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
    }
    
    func applyToLinkCell(cell: LinkCell) {
        cell.titleLabel.font = linkTitleFont
        cell.authorLabel.font = linkDetailsFont
        cell.ageLabel.font = linkCommentsFont
        
        if cell.styled { return }
        cell.styled = true
        
        cell.backgroundColor = lightColor
        cell.contentView.backgroundColor = lightColor
        cell.selectionStyle = .None
        cell.layoutMargins = UIEdgeInsets(top: 16.0, left: 8.0, bottom: 16.0, right: 8.0)
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
        
        cell.titleLabel.numberOfLines = 0
        cell.titleLabel.lineBreakMode = .ByTruncatingTail
        cell.titleLabel.textColor = darkColor
        
        cell.ageLabel.textColor = redditUITextColor
        cell.ageLabel.lineBreakMode = .ByTruncatingTail
        
        cell.authorLabel.textColor = mediumColor
        cell.authorLabel.lineBreakMode = .ByTruncatingTail
    }
    
    func applyTo(cell: CommentCell) {
        cell.backgroundColor = lightColor
        cell.bodyLabel.backgroundColor = lightColor
        cell.bodyLabel.textColor = darkColor
        cell.separatorHeight = 1.0 / scale
        cell.insets = commentCellInsets
        cell.bodyLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        cell.separatorView.backgroundColor = translucentDarkColor
    }
}
