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
    // MARK: - Injected
    var path: NSString!
    var style: Style!
    var interactor: LinksInteractor!
    var actionController: LinksActionController!
    
    // MARK: - Model
    var pages = [Listing]()
    
    // MARK: - Actions
    var voteAction: ((Link, VoteDirection) -> ())!

    
    // MARK: - Cell sizing
    
    let textOnlyLinkSizingCell = TextOnlyLinkCell(style: .Default, reuseIdentifier: nil)
    let thumbnailLinkSizingCell = ThumbnailLinkCell(style: .Default, reuseIdentifier: nil)
    var cellHeightCache = [NSIndexPath:CGFloat]()

    
    // MARK: - Model display
    
    func addPage(links: Listing) {
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
    
    func fetchNext() {
        var request: SubredditRequest!
        
        if let lastPage = pages.last {
            if let lastLink = lastPage.children.last {
                request = SubredditRequest(path: path, after: lastLink.name)
            } else {
                request = SubredditRequest(path: path)
            }
        } else {
            request = SubredditRequest(path: path)
        }
        
        interactor.fetchLinks(request) { [weak self] (links, error) in
            if let strongSelf = self {
                if let nonNilError = error {
                    // Do nothing for now
                } else if let nonNilLinks = links {
                    strongSelf.addPage(nonNilLinks)
                }
            }
        }
    }

    
    // Mark: - Thumbnail loading
    
    func loadThumbnail(thumbnail: Thumbnail, key: NSIndexPath) -> UIImage? {
        return interactor.loadThumbnail(thumbnail, key: key) { [weak self] (indexPath, outcome) -> () in
            if let strongSelf = self {
                switch outcome {
                case .Success(let image):
                    strongSelf.thumbnailLoaded(image(), indexPath: indexPath)
                case .Failure(let error):
                    println(error())
                }
            }
        }
    }
    
    func thumbnailLoaded(image: UIImage, indexPath: NSIndexPath) {
        if tableView.decelerating { return }
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as ThumbnailLinkCell? {
            if !cell.isThumbnailSet {
                cell.thumbnailImageView.image = image
            }
        }
    }
    
    func displayThumbnailAtIndexPath(indexPath: NSIndexPath, inCell cell: UITableViewCell?) {
        let thing = pages[indexPath.section][indexPath.row]
        
        switch thing {
        case let link as Link:
            if let thumbnail = link.thumbnail {
                if let thumbnailCell = cell as? ThumbnailLinkCell {
                    if !thumbnailCell.isThumbnailSet {
                        thumbnailCell.thumbnailImageView.image = loadThumbnail(thumbnail, key: indexPath)
                    }
                }
            }
        default:
            fatalError("Unknown kind: \(thing.kind)")
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
        
        fetchNext()
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
        let actionController = self.actionController
        cell.commentsAction = {
            actionController.showComments(link)
        }
        cell.upvoteAction = { (selected) in
//            self.upvoteLink(link, upvote: selected)
        }
        cell.downvoteAction = { (selected) in
//            self.downvoteLink(link, downvote: selected)
        }
    }
    
    func configureTextOnlyLinkCell(cell: TextOnlyLinkCell, link: Link, indexPath: NSIndexPath) {
        style.applyToTextOnlyLinkCell(cell)
        cell.titleLabel.text = link.title
        cell.authorLabel.text = "\(link.author) · \(link.domain) · \(link.subreddit)"
        cell.commentsButton.setTitle("\(link.commentCount) comments", forState: .Normal)
        cell.vote(link.likes)
        let actionController = self.actionController
        cell.commentsAction = {
            actionController.showComments(link)
        }
        cell.upvoteAction = { (selected) in
//            self.upvoteLink(link, upvote: selected)
        }
        cell.downvoteAction = { (selected) in
//            self.downvoteLink(link, downvote: selected)
        }
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
        let thing = pages[indexPath.section][indexPath.row]
        
        switch thing {
        case let link as Link:
            if let thumbnail = link.thumbnail {
                let cell = tableView.dequeueReusableCellWithIdentifier("ThumbnailLinkCell", forIndexPath: indexPath) as ThumbnailLinkCell
                configureThumbnailLinkCell(cell, link: link, indexPath: indexPath)
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("TextOnlyLinkCell", forIndexPath: indexPath) as TextOnlyLinkCell
                configureTextOnlyLinkCell(cell, link: link, indexPath: indexPath)
                return cell
            }
        default:
            fatalError("Unknown kind: \(thing.kind)")
        }
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let cachedHeight = cellHeightCache[indexPath] {
            return cachedHeight
        } else {
            let thing = pages[indexPath.section][indexPath.row]
            
            switch thing {
            case let link as Link:
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
            default:
                fatalError("Unknown kind: \(thing.kind)")
            }
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        if indexPath.section >= pages.count || indexPath.row >= pages[indexPath.section].count {
            return nil
        } else {
            let thing = pages[indexPath.section][indexPath.row]
            
            switch thing {
            case let link as Link:
                var moreAction = UITableViewRowAction(style: .Normal, title: "More") { (action, indexPath) -> Void in
                    tableView.editing = false
                    let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: link.author, link.domain, link.subreddit, "Report", "Hide", "Share")
                    actionSheet.showInView(self.view)
                }
                moreAction.backgroundColor = UIColor(red: 255.0/255.0, green: 87.0/255.0, blue: 0.0/255.0, alpha: 1.0)
                
                return [moreAction]
            default:
                fatalError("Unknown kind: \(thing.kind)")
            }
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // If this isn't present the swipe doesn't work
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let thing = pages[indexPath.section][indexPath.row]
        
        switch thing {
        case let link as Link:
            actionController.displayLink(link)
        default:
            fatalError("Unknown kind: \(thing.kind)")
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Prevent image load during cell sizing by doing it here instead
        displayThumbnailAtIndexPath(indexPath, inCell: cell)
        
        if pages.count > tableView.numberOfSections() {
            return
        }
        
        if indexPath.section < pages.count - 1 {
            return
        }
        
        if indexPath.row < pages[indexPath.section].count / 2 {
            return
        }
        
        fetchNext()
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
