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
    // MARK: - Model
    var pages = [Listing<Link>]()
    
    // MARK: - Actions
    
    var showCommentsAction: ((Link) -> ())!
    var showLinkAction: ((Link) -> ())!
    var fetchNextPageAction: (() -> ())!
    var voteAction: ((Link, VoteDirection) -> ())!
    var loadThumbnailAction: ((String, NSIndexPath) -> UIImage?)!

    
    // MARK: - Cell sizing
    
    let textOnlyLinkSizingCell = TextOnlyLinkCell(style: .Default, reuseIdentifier: nil)
    let thumbnailLinkSizingCell = ThumbnailLinkCell(style: .Default, reuseIdentifier: nil)
    var cellHeightCache = [NSIndexPath:CGFloat]()

    
    // MARK: - Model display
    
    func addPage(links: Listing<Link>) {
        if links.count == 0 {
            return
        }
        
        let firstPage = pages.count == 0
        pages.append(links)
        
        if firstPage {
            showNextPage()
        }
    }

    func showNextPage() {
        if pages.count > tableView.numberOfSections() {
            tableView.beginUpdates()
            tableView.insertSections(NSIndexSet(index: pages.count - 1), withRowAnimation: .None)
            tableView.endUpdates()
        }
        
        if let refresh = refreshControl {
            if refresh.refreshing {
                refresh.endRefreshing()
            }
        }
    }
    
    
    // Mark: - Thumbnail loading
    
    func thumbnailLoaded(image: UIImage, indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as ThumbnailLinkCell? {
            cell.thumbnailImageView.image = image
        }
    }
    

    // MARK: - Cell actions
    
    func upvoteLink(link: Link, upvote: Bool) {
        if upvote {
            voteAction(link, .Upvote)
        } else {
            voteAction(link, .None)
        }
    }
    
    func downvoteLink(link: Link, downvote: Bool) {
        if downvote {
            voteAction(link, .Downvote)
        } else {
            voteAction(link, .None)
        }
    }

    
    // MARK: - Refresh
    
    func pullToRefreshValueChanged(control: UIRefreshControl) {
        resetCellHeightCache()
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
        }
        
        fetchNextPageAction()
    }
    
    func resetCellHeightCache() {
        cellHeightCache = [NSIndexPath:CGFloat]()
    }

    
    // MARK: - Cell configuration
    
    func configureThumbnailLinkCell(cell: ThumbnailLinkCell, link: Link, indexPath: NSIndexPath) {
        if !cell.styled {
            let style = UIApplication.services.style
            style.applyToThumbnailLinkCell(cell)
        }
        cell.thumbnailImageView.image = loadThumbnailAction(link.thumbnail, indexPath)
        cell.titleLabel.text = link.title
        cell.authorLabel.text = "\(link.author) · \(link.domain) · \(link.subreddit)"
        cell.commentsButton.setTitle("\(link.commentCount) comments", forState: .Normal)
        cell.vote(link.likes)
        cell.commentsAction = { [unowned self] in
            self.showCommentsAction(link)
        }
        cell.upvoteAction = { [unowned self] (selected) in
            self.upvoteLink(link, upvote: selected)
        }
        cell.downvoteAction = { [unowned self] (selected) in
            self.downvoteLink(link, downvote: selected)
        }
    }
    
    func configureTextOnlyLinkCell(cell: TextOnlyLinkCell, link: Link, indexPath: NSIndexPath) {
        if !cell.styled {
            let style = UIApplication.services.style
            style.applyToTextOnlyLinkCell(cell)
        }
        cell.titleLabel.text = link.title
        cell.authorLabel.text = "\(link.author) · \(link.domain) · \(link.subreddit)"
        cell.commentsButton.setTitle("\(link.commentCount) comments", forState: .Normal)
        cell.vote(link.likes)
        cell.commentsAction = { [unowned self] in
            self.showCommentsAction(link)
        }
        cell.upvoteAction = { [unowned self] (selected) in
            self.upvoteLink(link, upvote: selected)
        }
        cell.downvoteAction = { [unowned self] (selected) in
            self.downvoteLink(link, downvote: selected)
        }
    }

    
    // MARK: - UIView overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let style = UIApplication.services.style

        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = style.redditOrangeColor
        refreshControl?.addTarget(self, action: Selector("pullToRefreshValueChanged:"), forControlEvents: .ValueChanged)
        
        tableView.registerClass(TextOnlyLinkCell.self, forCellReuseIdentifier: "TextOnlyLinkCell")
        tableView.registerClass(ThumbnailLinkCell.self, forCellReuseIdentifier: "ThumbnailLinkCell")
        tableView.backgroundColor = style.lightColor
        tableView.separatorColor = style.mediumColor
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if pages.count == 0 {
            refreshLinks()
        }
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        resetCellHeightCache()
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return pages.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pages[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let link = pages[indexPath.section][indexPath.row]
        
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
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let cachedHeight = cellHeightCache[indexPath] {
            return cachedHeight
        } else {
            let link = pages[indexPath.section][indexPath.row]
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
        if indexPath.section >= pages.count || indexPath.row >= pages[indexPath.section].count {
            return nil
        } else {
            let link = pages[indexPath.section][indexPath.row]
            
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
        let link = pages[indexPath.section][indexPath.row]
        showLinkAction(link)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if pages.count > tableView.numberOfSections() {
            return
        }
        
        if indexPath.section < pages.count - 1 {
            return
        }
        
        if indexPath.row < pages[indexPath.section].count / 2 {
            return
        }
        
        fetchNextPageAction()
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        showNextPage()
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            showNextPage()
        }
    }
}
