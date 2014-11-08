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
    
    func performSort() {
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Hot", "New", "Rising", "Controversial", "Top", "Gilded", "Promoted")
        actionSheet.showInView(view)
    }

    func showComments(link: Link) {
        applicationStoryboard.showComments(link)
    }

    func upvoteLink(link: Link, upvote: Bool, key: NSIndexPath) {
        linksController.voteLink(link, direction: upvote ? .Upvote : .None, key: key)
    }
    
    func downvoteLink(link: Link, downvote: Bool, key: NSIndexPath) {
        linksController.voteLink(link, direction: downvote ? .Downvote : .None, key: key)
    }
    
    func configureThumbnailLinkCell(cell: ThumbnailLinkCell, link: Link, indexPath: NSIndexPath) {
        cell.thumbnailImageView.image = linksController.fetchThumbnail(link.thumbnail, key: indexPath)
        cell.titleLabel.text = link.title
        cell.authorLabel.text = "\(link.author) · \(link.domain) · \(link.subreddit)"
        cell.commentsButton.setTitle("\(link.commentCount) comments", forState: .Normal)
        cell.upvoteButton.selected = (link.likes == .Upvote)
        cell.downvoteButton.selected = (link.likes == .Downvote)
        cell.commentsAction = { [weak self] in
            if let strongSelf = self {
                strongSelf.showComments(link)
            }
        }
        cell.upvoteAction = { [weak self] (selected) in
            if let strongSelf = self {
                strongSelf.upvoteLink(link, upvote: selected, key: indexPath)
            }
        }
        cell.downvoteAction = { [weak self] (selected) in
            if let strongSelf = self {
                strongSelf.downvoteLink(link, downvote: selected, key: indexPath)
            }
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
    
    func configureTextOnlyLinkCell(cell: TextOnlyLinkCell, link: Link, indexPath: NSIndexPath) {
        cell.titleLabel.text = link.title
        cell.authorLabel.text = "\(link.author) · \(link.domain) · \(link.subreddit)"
        cell.commentsButton.setTitle("\(link.commentCount) comments", forState: .Normal)
        cell.upvoteButton.selected = (link.likes == .Upvote)
        cell.downvoteButton.selected = (link.likes == .Downvote)
        cell.commentsAction = { [weak self] in
            self?.showComments(link)
            return
        }
        cell.upvoteAction = { [weak self] (selected) in
            if let strongSelf = self {
                strongSelf.upvoteLink(link, upvote: selected, key: indexPath)
            }
        }
        cell.downvoteAction = { [weak self] (selected) in
            if let strongSelf = self {
                strongSelf.downvoteLink(link, downvote: selected, key: indexPath)
            }
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
        
        cell.commentsButton.setTitleColor(GlobalStyle().redditUITextColor, forState: .Normal)
        cell.commentsButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        cell.commentsButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        
        cell.authorLabel.textColor = GlobalStyle().mediumColor
        cell.authorLabel.font = UIFont.systemFontOfSize(11.0)
        cell.authorLabel.lineBreakMode = .ByTruncatingTail
    }
    
    func pullToRefreshValueChanged(control: UIRefreshControl) {
        dettach(linksController)
        linksController = applicationStoryboard.linksController(linksController.path, refresh: true)
        attach(linksController)
        tableView.reloadData()
        refreshLinks()
    }
    
    func refreshLinks() {
        if let refresh = refreshControl {
            if !refresh.refreshing {
                tableView.contentOffset = CGPoint(
                    x: tableView.contentOffset.x,
                    y: tableView.contentOffset.y - refresh.frame.height
                )
                refresh.beginRefreshing()
            }
            
            linksController.fetchLinks() { [weak self] in
                if let strongSelf = self {
                    strongSelf.showNextPage()
                    refresh.endRefreshing()
                }
            }
        } else {
            linksController.fetchLinks() { [weak self] in
                if let strongSelf = self {
                    strongSelf.showNextPage()
                }
            }
        }
    }
    
    func attach(controller: LinksController) {
        controller.linksError = { (error) in
            println(error)
        }
        
        controller.thumbnailLoaded = { [weak self] (image, indexPath) in
            if let blockSelf = self {
                if let cell = blockSelf.tableView.cellForRowAtIndexPath(indexPath) as? ThumbnailLinkCell {
                    cell.thumbnailImageView.image = image
                }
            }
        }
        controller.thumbnailError = { (error, indexPath) in
            println(error)
        }
        
        controller.voteFailure = { [weak self] (error, indexPath) in
            if let strongSelf = self {
                strongSelf.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            }
        }
    }
    
    func dettach(controller: LinksController) {
        controller.linksError = nil
        controller.thumbnailLoaded = nil
        controller.thumbnailError = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = style.redditOrangeColor
        refreshControl?.addTarget(self, action: Selector("pullToRefreshValueChanged:"), forControlEvents: .ValueChanged)
        
        tableView.registerClass(TextOnlyLinkCell.self, forCellReuseIdentifier: "TextOnlyLinkCell")
        tableView.registerClass(ThumbnailLinkCell.self, forCellReuseIdentifier: "ThumbnailLinkCell")
        tableView.backgroundColor = style.lightColor
        tableView.separatorColor = style.mediumColor
        tableView.tableFooterView = UIView()
        
        attach(linksController)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let visible = linksController.lastVisibleIndexPaths {
            let middleRow = visible.count / 2
            tableView.scrollToRowAtIndexPath(visible[middleRow], atScrollPosition: .Middle, animated: false)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if linksController.numberOfPages == 0 {
            refreshLinks()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        linksController.lastVisibleIndexPaths = tableView.indexPathsForVisibleRows() as? [NSIndexPath]
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return linksController.numberOfPages
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return linksController.numberOfLinks(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
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
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        if indexPath.section >= linksController.numberOfPages || indexPath.row >= linksController.numberOfLinks(indexPath.section) {
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
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let link = linksController[indexPath]
        applicationStoryboard.displayLink(link)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if linksController.numberOfPages > tableView.numberOfSections() {
            return
        }
        
        if indexPath.section < linksController.numberOfPages - 1 {
            return
        }
        
        if indexPath.row < linksController.numberOfLinks(indexPath.section) / 2 {
            return
        }
        
        linksController.fetchNext()
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        showNextPage()
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            showNextPage()
        }
    }
    
    func showNextPage() {
        if linksController.numberOfPages > tableView.numberOfSections() {
            tableView.beginUpdates()
            tableView.insertSections(NSIndexSet(index: linksController.numberOfPages - 1), withRowAnimation: .None)
            tableView.endUpdates()
        }
    }
}
