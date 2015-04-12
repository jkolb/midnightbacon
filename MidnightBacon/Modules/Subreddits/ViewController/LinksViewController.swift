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

class LinksViewController: UIViewController, ListViewDataSource, UIScrollViewDelegate, UIActionSheetDelegate, LinksDataControllerDelegate {
    // MARK: - Injected
    var style: Style!
    var dataController: LinksDataController!
    var listView: ListView!
    weak var delegate: LinksViewControllerDelegate!
    let ageFormatter = ThingAgeFormatter()
    var isDataLoaded = false
    
    
    // MARK: - Model display

    func showNextPage() {
        if !isDataLoaded {
            isDataLoaded = true
            listView.reloadData()
        }
//        if dataController.numberOfPages > tableView.numberOfSections() {
//            tableView.beginUpdates()
//            tableView.insertSections(NSIndexSet(index: dataController.numberOfPages - 1), withRowAnimation: .None)
//            tableView.endUpdates()
//        }
    }

    
    // Mark: - Thumbnail loading
    
    func loadThumbnail(thumbnail: Thumbnail, key: Int) -> UIImage? {
        return dataController.loadThumbnail(thumbnail, key: NSIndexPath(forRow: key, inSection: 0)) { [weak self] (indexPath, outcome) -> () in
            if let strongSelf = self {
                switch outcome {
                case .Success(let image):
                    strongSelf.thumbnailLoaded(image.unwrap, index: indexPath.row)
                case .Failure(let error):
                    println(error.unwrap)
                }
            }
        }
    }
    
    func thumbnailLoaded(image: UIImage, index: Int) {
        if listView.decelerating { return }
        
        if let cell = listView.cellForIndex(index) as? ThumbnailLinkCell {
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
    
    func displayThumbnailAtIndex(index: Int, inCell cell: ListViewCell?, animated: Bool) {
        let link = dataController.linkForIndexPath(NSIndexPath(forRow: index, inSection: 0))
        
        if let thumbnail = link.thumbnail {
            if let thumbnailCell = cell as? ThumbnailLinkCell {
                if !thumbnailCell.isThumbnailSet {
                    if animated {
                        UIView.transitionWithView(
                            thumbnailCell.thumbnailImageView,
                            duration: 0.5,
                            options: .TransitionCrossDissolve,
                            animations: {
                                thumbnailCell.thumbnailImageView.image = self.loadThumbnail(thumbnail, key: index)
                            },
                            completion: nil
                        )
                    } else {
                        thumbnailCell.thumbnailImageView.image = loadThumbnail(thumbnail, key: index)
                    }
                }
            }
        }
    }

    func refreshVisibleThumbnails() {
//        if let visibleIndexPaths = tableView.indexPathsForVisibleRows() as? [NSIndexPath] {
//            for indexPath in visibleIndexPaths {
//                let cell = tableView.cellForRowAtIndexPath(indexPath)
//                displayThumbnailAtIndexPath(indexPath, inCell: cell, animated: true)
//            }
//        }
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
//        if dataController.numberOfPages == 0 {
//            if let refresh = refreshControl {
//                if !refresh.refreshing {
//                    tableView.contentOffset = CGPoint(
//                        x: tableView.contentOffset.x,
//                        y: tableView.contentOffset.y - refresh.frame.height
//                    )
//                    refresh.beginRefreshing()
//                }
//            }
//        }
    }
    
    func linksDataControllerDidEndLoad(linksDataController: LinksDataController) {
//        if let refresh = refreshControl {
//            if refresh.refreshing {
//                refresh.endRefreshing()
//            }
//        }
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
        listView.reloadData()
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
        listView.reloadData()
    }
    
    // MARK: - UIView overrides
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func loadView() {
        listView = ListView()
        view = listView
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        style.linkCellFontsDidChange()
        
//        refreshControl = UIRefreshControl()
//        refreshControl?.tintColor = style.redditOrangeColor
//        refreshControl?.addTarget(self, action: Selector("pullToRefreshValueChanged:"), forControlEvents: .ValueChanged)
        
        listView.dataSource = self
        listView.delegate = self
        listView.registerClass(TextOnlyLinkCell.self, forCellReuseIdentifier: "TextOnlyLinkCell")
        listView.registerClass(ThumbnailLinkCell.self, forCellReuseIdentifier: "ThumbnailLinkCell")
        listView.backgroundColor = style.lightColor
        
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
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

    
    // MARK: - ListViewDataSource
    
    func numberOfItemsInListView(listView: ListView) -> Int {
        if dataController.numberOfPages == 0 {
            return 0
        }
        
        return dataController.numberOfLinksForPage(0)
    }
    
    func listView(listView: ListView, cellForItemAtIndex index: Int) -> ListViewCell {
        let link = dataController.linkForIndexPath(NSIndexPath(forRow: index, inSection: 0))
        
        if let thumbnail = link.thumbnail {
            let cell = listView.dequeueReusableCellWithIdentifier("ThumbnailLinkCell") as! ThumbnailLinkCell
            configureThumbnailLinkCell(cell, link: link, indexPath: NSIndexPath(forRow: index, inSection: 0))
            return cell
        } else {
            let cell = listView.dequeueReusableCellWithIdentifier("TextOnlyLinkCell") as! TextOnlyLinkCell
            configureTextOnlyLinkCell(cell, link: link, indexPath: NSIndexPath(forRow: index, inSection: 0))
            return cell
        }
    }
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
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
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // If this isn't present the swipe doesn't work
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let link = dataController.linkForIndexPath(indexPath)
        
        if let strongDelegate = delegate {
            strongDelegate.linksViewController(self, displayLink: link)
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Prevent image load during cell sizing by doing it here instead
//        displayThumbnailAtIndexPath(indexPath, inCell: cell, animated: false)
//        
//        if dataController.numberOfPages > tableView.numberOfSections() {
//            return
//        }
//        
//        if indexPath.section < dataController.numberOfPages - 1 {
//            return
//        }
//        
//        if indexPath.row < dataController.numberOfLinksForPage(indexPath.section) / 2 {
//            return
//        }
//        
//        dataController.fetchNext()
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
