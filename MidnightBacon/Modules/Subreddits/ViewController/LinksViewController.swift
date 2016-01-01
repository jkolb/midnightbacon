//
//  LinksViewController.swift
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
import FranticApparatus
import Reddit
import Common

protocol LinksViewControllerDelegate : class {
    func linksViewController(linksViewController: LinksViewController, displayLink link: Link)
    func linksViewController(linksViewController: LinksViewController, showCommentsForLink link: Link)
    func linksViewController(linksViewController: LinksViewController, voteForLink link: Link, direction: VoteDirection)
}

class LinksViewController: TableViewController, LinksDataControllerDelegate {
    // MARK: - Injected
    var style: Style!
    var dataController: LinksDataController!
    var refreshControl: UIRefreshControl!
    weak var delegate: LinksViewControllerDelegate!
    let ageFormatter = ThingAgeFormatter()
    let thumbnailSizingCell = ThumbnailLinkCell()
    let textOnlySizingCell = TextOnlyLinkCell()
    var cellHeightCache = [NSIndexPath:CGFloat]()
    private var sharingLink: Link?
    
    init() {
        super.init(style: .Plain)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Model display

    func showNextPage() {
        if dataController.numberOfPages > tableView.numberOfSections {
            tableView.beginUpdates()
            tableView.insertSections(NSIndexSet(index: dataController.numberOfPages - 1), withRowAnimation: .None)
            tableView.endUpdates()
        }
    }

    
    // Mark: - Thumbnail loading
    
    func loadThumbnail(thumbnail: Thumbnail, key: NSIndexPath) -> UIImage? {
        return dataController.loadThumbnail(thumbnail, key: key) { [weak self] (indexPath, image, error) -> Void in
            if let strongSelf = self {
                if let image = image {
                    strongSelf.thumbnailLoaded(image, indexPath: indexPath)
                }
                else {
                    print(error)
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
        for indexPath in tableView.indexPathsForVisibleRows ?? [] {
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
    
    func linksDataController(linksDataController: LinksDataController, didFailWithReason reason: ErrorType) {
        let alertView = UIAlertView(title: "Error", message: "\(reason)", delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
    }

    
    // MARK: - Refresh
    
    func pullToRefreshValueChanged(control: UIRefreshControl) {
        dataController.refresh()
        cellHeightCache.removeAll(keepCapacity: true)
        tableView.reloadData()
    }

    
    // MARK: - Cell configuration
    func applyToTextOnlyCell(cell: TextOnlyLinkCell) {
        applyToLinkCell(cell)
    }
    
    func applyToThumbnailCell(cell: ThumbnailLinkCell) {
        cell.thumbnailImageView.layer.masksToBounds = true
        cell.thumbnailImageView.contentMode = .ScaleAspectFit
        cell.thumbnailImageView.layer.cornerRadius = 4.0
        cell.thumbnailImageView.layer.borderWidth = 1.0 / style.scale
        cell.thumbnailImageView.layer.borderColor = style.darkColor.colorWithAlphaComponent(0.2).CGColor
        
        applyToLinkCell(cell)
    }
    
    func applyToLinkCell(cell: LinkCell) {
        cell.titleLabel.font = style.linkTitleFont
        cell.authorLabel.font = style.linkDetailsFont
        cell.ageLabel.font = style.linkCommentsFont
        
        if cell.styled { return }
        cell.styled = true
        
        cell.backgroundColor = style.lightColor
        
        cell.titleLabel.numberOfLines = 0
        cell.titleLabel.lineBreakMode = .ByTruncatingTail
        cell.titleLabel.textColor = style.darkColor
        
        cell.ageLabel.textColor = style.redditUITextColor
        cell.ageLabel.lineBreakMode = .ByTruncatingTail
        
        cell.authorLabel.textColor = style.mediumColor
        cell.authorLabel.lineBreakMode = .ByTruncatingTail
        
        cell.separatorHeight = 1.0 / style.scale
        cell.insets = style.cellInsets
        cell.separatorView.backgroundColor = style.translucentDarkColor
    }

    func configureThumbnailLinkCell(cell: ThumbnailLinkCell, link: Link, indexPath: NSIndexPath) {
        applyToThumbnailCell(cell)
        
        if link.stickied {
            cell.titleLabel.textColor = style.redditOrangeRedColor
        } else {
            cell.titleLabel.textColor = style.darkColor
        }
        cell.titleLabel.text = link.title
        cell.authorLabel.text = "\(link.author) · \(link.domain) · \(link.subreddit)"
        cell.ageLabel.text = submittedAgeOfLink(link)
    }
    
    func configureTextOnlyLinkCell(cell: TextOnlyLinkCell, link: Link, indexPath: NSIndexPath) {
        applyToTextOnlyCell(cell)
        
        if link.stickied {
            cell.titleLabel.textColor = style.redditOrangeRedColor
        } else {
            cell.titleLabel.textColor = style.darkColor
        }
        cell.titleLabel.text = link.title
        cell.authorLabel.text = "\(link.author) · \(link.domain) · \(link.subreddit)"
        cell.ageLabel.text = submittedAgeOfLink(link)
    }

    func submittedAgeOfLink(link: Link) -> String {
        if let age = ageFormatter.stringForDate(link.created) {
            return "submitted \(age)"
        } else {
            return ""
        }
    }
    
    func contentSizeCategoryDidChangeNotification(notification: NSNotification) {
        style.linkCellFontsDidChange()
        cellHeightCache.removeAll(keepCapacity: true)
        tableView.reloadData()
    }
    
    
    // MARK: - UIView overrides
    
    deinit {
        tableView.delegate = nil
        tableView.dataSource = nil
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = style.lightColor
        tableView.layoutMargins = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.separatorColor = style.mediumColor
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
        style.linkCellFontsDidChange()
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = style.redditOrangeColor
        refreshControl.addTarget(self, action: Selector("pullToRefreshValueChanged:"), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataController.numberOfPages
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataController.numberOfLinksForPage(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let link = dataController.linkForIndexPath(indexPath)
        
        if let _ = link.thumbnail {
            let cell = tableView.dequeueReusableCellWithIdentifier("ThumbnailLinkCell", forIndexPath: indexPath) as! ThumbnailLinkCell
            configureThumbnailLinkCell(cell, link: link, indexPath: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("TextOnlyLinkCell", forIndexPath: indexPath) as! TextOnlyLinkCell
            configureTextOnlyLinkCell(cell, link: link, indexPath: indexPath)
            return cell
        }
    }
}

extension LinksViewController {
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
            
            let moreAction = UITableViewRowAction(style: .Normal, title: "More") { (action, indexPath) -> Void in
                tableView.editing = false
                let actionSheet = UIActionSheet(title: "More", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: link.author, link.domain, link.subreddit, "Report", "Hide", "Share")
                self.sharingLink = link
                actionSheet.showInView(self.view)
            }
            moreAction.backgroundColor = style.redditOrangeRedColor
            
            let commentsTitle = "\(link.commentCount)\nComments"
            let commentsAction = UITableViewRowAction(style: .Normal, title: commentsTitle) { [weak self] (action, indexPath) in
                tableView.editing = false
                self?.showCommentsForLink(link)
            }
            commentsAction.backgroundColor = style.redditUITextColor
            
            let voteAction = UITableViewRowAction(style: .Normal, title: "Vote") { (action, indexPath) in
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
        
        if dataController.numberOfPages > tableView.numberOfSections {
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
            
            if let _ = link.thumbnail {
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
}

extension LinksViewController {
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

extension LinksViewController : UIActionSheetDelegate {
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if let link = sharingLink {
            if buttonIndex == 6 {
                let activityViewController = UIActivityViewController(activityItems: [link.url], applicationActivities: nil)
                navigationController?.presentViewController(activityViewController, animated: true, completion: nil)
            }
            
            sharingLink = nil
        }
    }
}
