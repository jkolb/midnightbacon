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

class LinksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIActionSheetDelegate, LinksDataControllerDelegate {
    // MARK: - Injected
    var style: Style!
    var dataController: LinksDataController!
    var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    weak var delegate: LinksViewControllerDelegate!
    let ageFormatter = ThingAgeFormatter()
    let thumbnailSizingCell = ThumbnailLinkCell()
    let textOnlySizingCell = TextOnlyLinkCell()
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
                UIView.transitionWithView(
                    cell.thumbnailImageView,
                    duration: 0.5,
                    options: .TransitionCrossDissolve,
                    animations: {
                        cell.thumbnailImageView.image = image
                    },
                    completion: nil
                )
            }
        }
    }
    
    func displayThumbnailAtIndexPath(indexPath: NSIndexPath, inCell cell: ThumbnailLinkCell, animated: Bool) {
        let link = dataController.linkForIndexPath(indexPath)
        
        if let thumbnail = link.thumbnail {
            if !cell.isThumbnailSet {
                if animated {
                    UIView.transitionWithView(
                        cell.thumbnailImageView,
                        duration: 0.5,
                        options: .TransitionCrossDissolve,
                        animations: {
                            cell.thumbnailImageView.image = self.loadThumbnail(thumbnail, key: indexPath)
                        },
                        completion: nil
                    )
                } else {
                    cell.thumbnailImageView.image = loadThumbnail(thumbnail, key: indexPath)
                }
            }
        }
    }

    func refreshVisibleThumbnails() {
        for indexPath in tableView.indexPathsForVisibleRows() as? [NSIndexPath] ?? [] {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ThumbnailLinkCell {
                displayThumbnailAtIndexPath(indexPath, inCell: cell, animated: true)
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
            if !refreshControl.refreshing {
                tableView.contentOffset = CGPoint(
                    x: tableView.contentOffset.x,
                    y: tableView.contentOffset.y - refreshControl.frame.height
                )
                refreshControl.beginRefreshing()
            }
        }
    }
    
    func linksDataControllerDidEndLoad(linksDataController: LinksDataController) {
        if refreshControl.refreshing {
            refreshControl.endRefreshing()
        }
    }
    
    func linksDataControllerDidLoadLinks(linksDataController: LinksDataController) {
        showNextPage()
    }
    
    func linksDataController(linksDataController: LinksDataController, didFailWithReason reason: Error) {
        let alertView = UIAlertView(title: "Error", message: reason.description, delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
    }

    
    // MARK: - Refresh
    
    func pullToRefreshValueChanged(control: UIRefreshControl) {
        dataController.refresh()
        cellHeightCache.removeAll(keepCapacity: true)
        tableView.reloadData()
    }

    
    // MARK: - Cell configuration
    
    func configureThumbnailLinkCell(cell: ThumbnailLinkCell, link: Link, indexPath: NSIndexPath) {
        style.applyTo(cell)
        cell.titleLabel.text = link.title
        cell.authorLabel.text = "\(link.author) · \(link.domain) · \(link.subreddit)"
        cell.ageLabel.text = ageFormatter.stringForDate(link.created)
    }
    
    func configureTextOnlyLinkCell(cell: TextOnlyLinkCell, link: Link, indexPath: NSIndexPath) {
        style.applyTo(cell)
        cell.titleLabel.text = link.title
        cell.authorLabel.text = "\(link.author) · \(link.domain) · \(link.subreddit)"
        cell.ageLabel.text = ageFormatter.stringForDate(link.created)
    }

    func contentSizeCategoryDidChangeNotification(notification: NSNotification) {
        style.linkCellFontsDidChange()
        cellHeightCache.removeAll(keepCapacity: true)
        tableView.reloadData()
    }
    
    
    // MARK: - UIView overrides
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func loadView() {
        tableView = UITableView()
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        style.linkCellFontsDidChange()
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = style.redditOrangeColor
        refreshControl.addTarget(self, action: Selector("pullToRefreshValueChanged:"), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .None
        tableView.backgroundColor = style.lightColor
        tableView.registerClass(TextOnlyLinkCell.self, forCellReuseIdentifier: "TextOnlyLinkCell")
        tableView.registerClass(ThumbnailLinkCell.self, forCellReuseIdentifier: "ThumbnailLinkCell")
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("contentSizeCategoryDidChangeNotification:"),
            name: UIContentSizeCategoryDidChangeNotification,
            object: nil
        )
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow() {
            tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if dataController.numberOfPages == 0 {
            dataController.fetchNext()
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        cellHeightCache.removeAll(keepCapacity: true)
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

    
    // MARK: - UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataController.numberOfPages
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataController.numberOfLinksForPage(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let link = dataController.linkForIndexPath(indexPath)

        if let strongDelegate = delegate {
            strongDelegate.linksViewController(self, displayLink: link)
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        if indexPath.section >= dataController.numberOfPages || indexPath.row >= dataController.numberOfLinksForPage(indexPath.section) {
            return nil
        } else {
            let link = dataController.linkForIndexPath(indexPath)
            
            var moreAction = UITableViewRowAction(style: .Normal, title: "More") { (action, indexPath) -> Void in
                tableView.editing = false
                let actionSheet = UIActionSheet(title: "More", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: link.author, link.domain, link.subreddit, "Report", "Hide", "Share")
                actionSheet.showInView(self.view)
            }
            moreAction.backgroundColor = style.redditOrangeRedColor
            
            let commentsTitle = "\(link.commentCount)\nComments"
            var commentsAction = UITableViewRowAction(style: .Normal, title: commentsTitle) { [weak self] (action, indexPath) in
                tableView.editing = false
                self?.showCommentsForLink(link)
            }
            commentsAction.backgroundColor = style.redditUITextColor
            
            var voteAction = UITableViewRowAction(style: .Normal, title: "Vote") { (action, indexPath) in
                tableView.editing = false
                let actionSheet = UIActionSheet(title: "Vote", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Upvote", "Downvote", "Clear Vote")
                actionSheet.showInView(self.view)
            }
            voteAction.backgroundColor = style.redditNeutralColor

            return [commentsAction, voteAction, moreAction]
        }
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // Required to show edit actions
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let thumbnailCell = cell as? ThumbnailLinkCell {
            // Prevent image load during cell sizing by doing it here instead
            displayThumbnailAtIndexPath(indexPath, inCell: thumbnailCell, animated: false)
        }
        
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let height = cellHeightCache[indexPath] {
            return height
        } else {
            let link = dataController.linkForIndexPath(indexPath)
            let fitSize = CGSize(width: tableView.bounds.width, height: 10_000.00)
            
            if let thumbnail = link.thumbnail {
                let cell = thumbnailSizingCell
                configureThumbnailLinkCell(cell, link: link, indexPath: indexPath)
                let height = cell.sizeThatFits(fitSize).height
                cellHeightCache[indexPath] = height
                return height
            } else {
                let cell = textOnlySizingCell
                configureTextOnlyLinkCell(cell, link: link, indexPath: indexPath)
                let height = cell.sizeThatFits(fitSize).height
                cellHeightCache[indexPath] = height
                return height
            }
        }
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        showNextPage()
        refreshVisibleThumbnails()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            showNextPage()
            refreshVisibleThumbnails()
        }
    }
}
