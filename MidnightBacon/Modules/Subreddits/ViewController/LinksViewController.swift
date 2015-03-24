//
//  LinksViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

protocol LinksViewControllerDelegate : class {
    func linksViewController(linksViewController: LinksViewController, displayLink link: Link)
    func linksViewController(linksViewController: LinksViewController, showCommentsForLink link: Link)
    func linksViewController(linksViewController: LinksViewController, voteForLink link: Link, direction: VoteDirection)
}

class LinksViewController: UITableViewController, LinkCellDelegate, UIActionSheetDelegate, LinksDataControllerDelegate {
    // MARK: - Injected
    var style: Style!
    var dataController: LinksDataController!
    weak var delegate: LinksViewControllerDelegate!

    // MARK: - Cell sizing
    
    let textOnlyLinkSizingCell = TextOnlyLinkCell(style: .Default, reuseIdentifier: nil)
    let thumbnailLinkSizingCell = ThumbnailLinkCell(style: .Default, reuseIdentifier: nil)
    var cellHeightCache = [NSIndexPath:CGFloat]()

    
    // MARK: - Model display

    func showNextPage() {
        if dataController.numberOfPages > tableView.numberOfSections() {
            tableView.beginUpdates()
            tableView.insertSections(NSIndexSet(index: dataController.numberOfPages - 1), withRowAnimation: .None)
            tableView.endUpdates()
        }
    }

    
    // Mark: - Thumbnail loading
    
    func loadThumbnail(thumbnail: Thumbnail, key: NSIndexPath) -> UIImage? {
        return dataController.loadThumbnail(thumbnail, key: key) { [weak self] (indexPath, outcome) -> () in
            if let strongSelf = self {
                switch outcome {
                case .Success(let image):
                    strongSelf.thumbnailLoaded(image.unwrap, indexPath: indexPath)
                case .Failure(let error):
                    println(error.unwrap)
                }
            }
        }
    }
    
    func thumbnailLoaded(image: UIImage, indexPath: NSIndexPath) {
        if tableView.decelerating { return }
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ThumbnailLinkCell {
            if !cell.isThumbnailSet {
                cell.thumbnailImageView.image = image
            }
        }
    }
    
    func displayThumbnailAtIndexPath(indexPath: NSIndexPath, inCell cell: UITableViewCell?) {
        let link = dataController.linkForIndexPath(indexPath)
        
        if let thumbnail = link.thumbnail {
            if let thumbnailCell = cell as? ThumbnailLinkCell {
                if !thumbnailCell.isThumbnailSet {
                    thumbnailCell.thumbnailImageView.image = loadThumbnail(thumbnail, key: indexPath)
                }
            }
        }
    }

    func refreshVisibleThumbnails() {
        if let visibleIndexPaths = tableView.indexPathsForVisibleRows() as? [NSIndexPath] {
            for indexPath in visibleIndexPaths {
                let cell = tableView.cellForRowAtIndexPath(indexPath)
                displayThumbnailAtIndexPath(indexPath, inCell: cell)
            }
        }
    }
    
    
    // MARK: Delegate helpers
    
    func showCommentsForLink(link: Link) {
        if let strongDelegate = delegate {
            strongDelegate.linksViewController(self, showCommentsForLink: link)
        }
    }
    
    func voteForLink(link: Link, direction: VoteDirection) {
        if let strongDelegate = delegate {
            strongDelegate.linksViewController(self, voteForLink: link, direction: direction)
        }
    }
    
    
    // MARK: - LinksDataControllerDelegate

    func linksDataControllerDidBeginLoad(linksDataController: LinksDataController) {
        if dataController.numberOfPages == 0 {
            if let refresh = refreshControl {
                if !refresh.refreshing {
                    tableView.contentOffset = CGPoint(
                        x: tableView.contentOffset.x,
                        y: tableView.contentOffset.y - refresh.frame.height
                    )
                    refresh.beginRefreshing()
                }
            }
        }
    }
    
    func linksDataControllerDidEndLoad(linksDataController: LinksDataController) {
        if let refresh = refreshControl {
            if refresh.refreshing {
                refresh.endRefreshing()
            }
        }
    }
    
    func linksDataControllerDidLoadLinks(linksDataController: LinksDataController) {
        showNextPage()
    }
    
    func linksDataController(linksDataController: LinksDataController, didFailWithReason reason: Error) {
        let alertView = UIAlertView(title: "Error", message: reason.description, delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
    }

    
    // MARK: - LinkCellDelegate
    
    func linkCellRequestComments(linkCell: LinkCell) {
        performWithLinkForCell(linkCell) { (link) in
            self.showCommentsForLink(link)
        }
    }
    
    func linkCellRequestUpvote(linkCell: LinkCell, selected: Bool) {
        performWithLinkForCell(linkCell) { (link) in
            self.upvoteLink(link, upvote: selected)
        }
    }
    
    func linkCellRequestDownvote(linkCell: LinkCell, selected: Bool) {
        performWithLinkForCell(linkCell) { (link) in
            self.downvoteLink(link, downvote: selected)
        }
    }
    
    func performWithLinkForCell(linkCell: LinkCell, perform: (Link) -> ()) {
        if let indexPath = tableView.indexPathForCell(linkCell) {
            let link = dataController.linkForIndexPath(indexPath)
            perform(link)
        }
    }


    func upvoteLink(link: Link, upvote: Bool) {
        if upvote {
            voteForLink(link, direction: .Upvote)
        } else {
            voteForLink(link, direction: .None)
        }
    }
    
    func downvoteLink(link: Link, downvote: Bool) {
        if downvote {
            voteForLink(link, direction: .Downvote)
        } else {
            voteForLink(link, direction: .None)
        }
    }

    
    // MARK: - Refresh
    
    func pullToRefreshValueChanged(control: UIRefreshControl) {
        resetCellHeightCache()
        dataController.refresh()
        tableView.reloadData()
    }
    
    func resetCellHeightCache() {
        cellHeightCache.removeAll(keepCapacity: true)
    }

    
    // MARK: - Cell configuration

    func configureThumbnailLinkCell(cell: ThumbnailLinkCell, link: Link, indexPath: NSIndexPath) {
        style.applyToThumbnailLinkCell(cell)
        cell.titleLabel.text = link.title
        cell.authorLabel.text = "\(link.author) · \(link.domain) · \(link.subreddit)"
        cell.commentsButton.setTitle("\(link.commentCount) comments", forState: .Normal)
        cell.vote(link.likes)
        cell.delegate = self
    }
    
    func configureTextOnlyLinkCell(cell: TextOnlyLinkCell, link: Link, indexPath: NSIndexPath) {
        style.applyToTextOnlyLinkCell(cell)
        cell.titleLabel.text = link.title
        cell.authorLabel.text = "\(link.author) · \(link.domain) · \(link.subreddit)"
        cell.commentsButton.setTitle("\(link.commentCount) comments", forState: .Normal)
        cell.vote(link.likes)
        cell.delegate = self
    }

    func contentSizeCategoryDidChangeNotification(notification: NSNotification) {
        style.linkCellFontsDidChange()
        resetCellHeightCache()
        tableView.reloadData()
    }
    
    // MARK: - UIView overrides
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        style.linkCellFontsDidChange()
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = style.redditOrangeColor
        refreshControl?.addTarget(self, action: Selector("pullToRefreshValueChanged:"), forControlEvents: .ValueChanged)
        
        tableView.registerClass(TextOnlyLinkCell.self, forCellReuseIdentifier: "TextOnlyLinkCell")
        tableView.registerClass(ThumbnailLinkCell.self, forCellReuseIdentifier: "ThumbnailLinkCell")
        tableView.backgroundColor = style.lightColor
        tableView.separatorColor = style.mediumColor
        tableView.tableFooterView = UIView()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("contentSizeCategoryDidChangeNotification:"),
            name: UIContentSizeCategoryDidChangeNotification,
            object: nil
        )
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if dataController.numberOfPages == 0 {
            dataController.fetchNext()
        }
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        resetCellHeightCache()
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataController.numberOfPages
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataController.numberOfLinksForPage(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let link = dataController.linkForIndexPath(indexPath)
        
        if let thumbnail = link.thumbnail {
            let cell = tableView.dequeueReusableCellWithIdentifier("ThumbnailLinkCell", forIndexPath: indexPath) as! ThumbnailLinkCell
            configureThumbnailLinkCell(cell, link: link, indexPath: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("TextOnlyLinkCell", forIndexPath: indexPath) as! TextOnlyLinkCell
            configureTextOnlyLinkCell(cell, link: link, indexPath: indexPath)
            return cell
        }
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let cachedHeight = cellHeightCache[indexPath] {
            return cachedHeight
        } else {
            let link = dataController.linkForIndexPath(indexPath)
            
            var cell: UITableViewCell!
            
            if let thumbnail = link.thumbnail {
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
        if indexPath.section >= dataController.numberOfPages || indexPath.row >= dataController.numberOfLinksForPage(indexPath.section) {
            return nil
        } else {
            let link = dataController.linkForIndexPath(indexPath)
            
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
        let link = dataController.linkForIndexPath(indexPath)
        
        if let strongDelegate = delegate {
            strongDelegate.linksViewController(self, displayLink: link)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Prevent image load during cell sizing by doing it here instead
        displayThumbnailAtIndexPath(indexPath, inCell: cell)
        
        if dataController.numberOfPages > tableView.numberOfSections() {
            return
        }
        
        if indexPath.section < dataController.numberOfPages - 1 {
            return
        }
        
        if indexPath.row < dataController.numberOfLinksForPage(indexPath.section) / 2 {
            return
        }
        
        dataController.fetchNext()
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        showNextPage()
        refreshVisibleThumbnails()
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            showNextPage()
            refreshVisibleThumbnails()
        }
    }
}
