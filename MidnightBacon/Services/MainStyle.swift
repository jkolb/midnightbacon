//
//  MainStyle.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

struct MainStyle : Style {
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
    
    func configureGlobalAppearance() {
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: redditUITextColor]
    }
    
    func createMainWindow() -> UIWindow {
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.tintColor = redditUITextColor
        return window
    }

    func barButtonItem(# title: String, tintColor: UIColor, action: TargetAction) -> UIBarButtonItem {
        let button = UIBarButtonItem(title: title, style: .Plain, action: action)
        let font = UIFont(name: "Helvetica", size: 24.0)
        let attributes = NSMutableDictionary()
        attributes[NSFontAttributeName] = font
        button.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
        button.tintColor = tintColor
        return button
    }
    
    func barButtonItem(# title: String, tintColor: UIColor, target: AnyObject?, action: Selector) -> UIBarButtonItem {
        let button = UIBarButtonItem(title: title, style: .Plain, target: target, action: action)
        button.tintColor = tintColor
        return button
    }
    
    func symbolBarButtonItem(# title: String, tintColor: UIColor, target: AnyObject?, action: Selector) -> UIBarButtonItem {
        let button = UIBarButtonItem(title: title, style: .Plain, target: target, action: action)
        let font = UIFont(name: "Helvetica", size: 24.0)
        let attributes = NSMutableDictionary()
        attributes[NSFontAttributeName] = font
        button.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
        button.tintColor = tintColor
        return button
    }
    
    func applyTo(viewController: TableViewController) {
        viewController.tableView.backgroundColor = lightColor
        viewController.tableView.layoutMargins = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        viewController.tableView.separatorColor = mediumColor
        viewController.tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
    }
    
    func applyToTextOnlyLinkCell(cell: TextOnlyLinkCell) {
        applyToLinkCell(cell)
    }
    
    func applyToThumbnailLinkCell(cell: ThumbnailLinkCell) {
        let style = UIApplication.services.style
        cell.thumbnailImageView.layer.masksToBounds = true
        cell.thumbnailImageView.contentMode = .ScaleAspectFit
        cell.thumbnailImageView.layer.cornerRadius = 4.0
        cell.thumbnailImageView.layer.borderWidth = 1.0 / scale
        cell.thumbnailImageView.layer.borderColor = style.darkColor.colorWithAlphaComponent(0.2).CGColor
        
        applyToLinkCell(cell)
    }
    
    func applyToLinkCell(cell: LinkCell) {
        cell.styled = true
        
        let style = UIApplication.services.style
        
        cell.backgroundColor = style.lightColor
        cell.contentView.backgroundColor = style.lightColor
        cell.selectionStyle = .None
        cell.layoutMargins = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
        
        cell.upvoteButton.setTitle("⬆︎", forState: .Normal)
        cell.upvoteButton.setTitleColor(style.redditUpvoteColor, forState: .Highlighted)
        cell.upvoteButton.setTitleColor(style.redditUpvoteColor, forState: .Selected)
        cell.upvoteButton.setTitleColor(style.mediumColor, forState: .Normal)
        cell.upvoteButton.layer.cornerRadius = 4.0
        cell.upvoteButton.layer.borderWidth = 1.0
        cell.upvoteButton.layer.borderColor = style.mediumColor.CGColor
        
        cell.downvoteButton.setTitle("⬆︎", forState: .Normal)
        cell.downvoteButton.transform = CGAffineTransformMakeScale(1.0, -1.0)
        cell.downvoteButton.setTitleColor(style.redditDownvoteColor, forState: .Highlighted)
        cell.downvoteButton.setTitleColor(style.redditDownvoteColor, forState: .Selected)
        cell.downvoteButton.setTitleColor(style.mediumColor, forState: .Normal)
        cell.downvoteButton.layer.cornerRadius = 4.0
        cell.downvoteButton.layer.borderWidth = 1.0
        cell.downvoteButton.layer.borderColor = style.mediumColor.CGColor
        
        cell.titleLabel.numberOfLines = 0
        cell.titleLabel.lineBreakMode = .ByTruncatingTail
        cell.titleLabel.textColor = style.darkColor
        cell.titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        
        cell.commentsButton.setTitleColor(MainStyle().redditUITextColor, forState: .Normal)
        cell.commentsButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        cell.commentsButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        
        cell.authorLabel.textColor = MainStyle().mediumColor
        cell.authorLabel.font = UIFont.systemFontOfSize(11.0)
        cell.authorLabel.lineBreakMode = .ByTruncatingTail
    }
}
