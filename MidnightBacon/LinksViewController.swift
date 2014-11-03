//
//  LinksViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

class LinksViewController: UITableViewController, UIActionSheetDelegate {
    var linksController: LinksController!
    weak var applicationStoryboard: ApplicationStoryboard!
    let textOnlyLinkSizingCell = TextOnlyLinkCell(style: .Default, reuseIdentifier: nil)
    let thumbnailLinkSizingCell = ThumbnailLinkCell(style: .Default, reuseIdentifier: nil)
    var cellHeightCache = [NSIndexPath:CGFloat]()
    var scale: CGFloat = 1.0
    let style = GlobalStyle()
    var firstLoad = true
    var activityHeight: CGFloat = 0.0
    
    func performSort() {
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Hot", "New", "Rising", "Controversial", "Top", "Gilded", "Promoted")
        actionSheet.showInView(view)
    }

    func showComments(link: Reddit.Link) {
        applicationStoryboard.showComments(link)
    }

    func configureThumbnailLinkCell(cell: ThumbnailLinkCell, link: Reddit.Link, indexPath: NSIndexPath) {
        cell.thumbnailImageView.image = linksController.fetchThumbnail(link.thumbnail, key: indexPath)
        cell.titleLabel.text = link.title
        cell.authorLabel.text = "\(link.author) · \(link.domain) · \(link.subreddit)"
        cell.commentsButton.setTitle("\(link.commentCount) comments", forState: .Normal)
        cell.commentsAction = { [weak self] in
            self?.showComments(link)
            return
        }
        
        if !cell.styled {
            styleThumbnailLinkCell(cell)
        }
    }
    
    func styleThumbnailLinkCell(cell: ThumbnailLinkCell) {
        cell.thumbnailImageView.layer.masksToBounds = true
        cell.thumbnailImageView.contentMode = .ScaleAspectFit
        cell.thumbnailImageView.layer.cornerRadius = 4.0
        cell.thumbnailImageView.layer.borderWidth = 1.0 / scale
        cell.thumbnailImageView.layer.borderColor = style.darkColor.colorWithAlphaComponent(0.2).CGColor
        
        styleLinkCell(cell)
    }
    
    func configureTextOnlyLinkCell(cell: TextOnlyLinkCell, link: Reddit.Link, indexPath: NSIndexPath) {
        cell.titleLabel.text = link.title
        cell.authorLabel.text = "\(link.author) · \(link.domain) · \(link.subreddit)"
        cell.commentsButton.setTitle("\(link.commentCount) comments", forState: .Normal)
        cell.commentsAction = { [weak self] in
            self?.showComments(link)
            return
        }

        if !cell.styled {
            styleTextOnlyLinkCell(cell)
        }
    }
    
    func styleTextOnlyLinkCell(cell: TextOnlyLinkCell) {
        styleLinkCell(cell)
    }
    
    func styleLinkCell(cell: LinkCell) {
        cell.styled = true
        
        cell.backgroundColor = style.lightColor
        cell.contentView.backgroundColor = style.lightColor
        cell.selectionStyle = .None
        cell.layoutMargins = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
        
        cell.upvoteButton.setTitle("⬆︎", forState: .Normal)
        cell.upvoteButton.setTitleColor(style.redditUpvoteColor, forState: .Normal)
        cell.upvoteButton.layer.cornerRadius = 4.0
        cell.upvoteButton.layer.borderWidth = 1.0
        cell.upvoteButton.layer.borderColor = style.redditUpvoteColor.CGColor
        
        cell.downvoteButton.setTitle("⬆︎", forState: .Normal)
        cell.downvoteButton.transform = CGAffineTransformMakeScale(1.0, -1.0)
        cell.downvoteButton.setTitleColor(style.redditDownvoteColor, forState: .Normal)
        cell.downvoteButton.layer.cornerRadius = 4.0
        cell.downvoteButton.layer.borderWidth = 1.0
        cell.downvoteButton.layer.borderColor = style.redditDownvoteColor.CGColor
        
        cell.titleLabel.numberOfLines = 0
        cell.titleLabel.lineBreakMode = .ByTruncatingTail
        cell.titleLabel.textColor = style.darkColor
        cell.titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        
        cell.commentsButton.setTitleColor(GlobalStyle().redditUITextColor, forState: .Normal)
        cell.commentsButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        cell.commentsButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        
        cell.authorLabel.textColor = GlobalStyle().mediumColor
        cell.authorLabel.font = UIFont.systemFontOfSize(11.0)
        cell.authorLabel.lineBreakMode = .ByTruncatingTail
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(ActivityIndicatorCell.self, forCellReuseIdentifier: "ActivityCell")
        tableView.registerClass(TextOnlyLinkCell.self, forCellReuseIdentifier: "TextOnlyLinkCell")
        tableView.registerClass(ThumbnailLinkCell.self, forCellReuseIdentifier: "ThumbnailLinkCell")
        tableView.backgroundColor = style.lightColor
        tableView.separatorColor = style.mediumColor
        tableView.tableFooterView = UIView()
        
        linksController.linksLoaded = { [weak self] in
            self?.tableView.reloadData()
            return
        }

        linksController.linksError = { (error) in
            println(error)
        }
        
        linksController.thumbnailLoaded = { [weak self] (image, indexPath) in
            if let blockSelf = self {
                if let cell = blockSelf.tableView.cellForRowAtIndexPath(indexPath) as? ThumbnailLinkCell {
                    cell.thumbnailImageView.image = image
                }
            }
        }
        linksController.thumbnailError = { (error, indexPath) in
            println(error)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstLoad {
            linksController.fetchLinks()
            firstLoad = false
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return linksController.count + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == linksController.count {
            let cell = tableView.dequeueReusableCellWithIdentifier("ActivityCell", forIndexPath: indexPath) as ActivityIndicatorCell
            cell.activityIndicatorView.startAnimating()
            cell.layoutMargins = UIEdgeInsetsZero
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: tableView.bounds.width)
            cell.selectionStyle = .None
            return cell
        } else {
            let link = linksController[indexPath]
            
            if link.hasThumbnail {
                let cell = tableView.dequeueReusableCellWithIdentifier("ThumbnailLinkCell", forIndexPath: indexPath) as ThumbnailLinkCell
                configureThumbnailLinkCell(cell, link: link, indexPath: indexPath)
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("TextOnlyLinkCell", forIndexPath: indexPath) as TextOnlyLinkCell
                configureTextOnlyLinkCell(cell, link: link, indexPath: indexPath)
                return cell
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == linksController.count {
            if activityHeight == 0.0 {
                let activityCell = ActivityIndicatorCell(style: .Default, reuseIdentifier: nil)
                let availableWidth = tableView.bounds.width
                let activitySize = activityCell.sizeThatFits(CGSize.fixedWidth(availableWidth))
                activityHeight = activitySize.height
            }
            
            return activityHeight
        } else {
            if let cachedHeight = cellHeightCache[indexPath] {
                return cachedHeight
            } else {
                let link = linksController[indexPath]
                var cell: UITableViewCell!
                
                if link.hasThumbnail {
                    configureThumbnailLinkCell(thumbnailLinkSizingCell, link: link, indexPath: indexPath)
                    cell = thumbnailLinkSizingCell
                } else {
                    configureTextOnlyLinkCell(textOnlyLinkSizingCell, link: link, indexPath: indexPath)
                    cell = textOnlyLinkSizingCell
                }
                
                let availableWidth = tableView.bounds.width
                let size = cell.sizeThatFits(CGSize.fixedWidth(availableWidth))
                let height = size.height
                cellHeightCache[indexPath] = height
                return height
            }
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        if indexPath.row == linksController.count {
            return nil
        } else {
            let link = linksController[indexPath]
            
            var moreAction = UITableViewRowAction(style: .Normal, title: "More") { (action, indexPath) -> Void in
                tableView.editing = false
                let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: link.author, link.domain, link.subreddit, "Report", "Hide", "Share")
                actionSheet.showInView(self.view)
            }
            moreAction.backgroundColor = UIColor(red: 255.0/255.0, green: 87.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            
            return [moreAction]
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // If this isn't present the swipe doesn't work
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == linksController.count {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < linksController.count {
            let link = linksController[indexPath]
            applicationStoryboard.displayLink(link)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        linksController.prefetch(indexPath)
    }
}
