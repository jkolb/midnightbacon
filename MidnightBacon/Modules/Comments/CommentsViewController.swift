//
//  CommentsViewController.swift
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

class CommentsViewController : UIViewController, CommentsDataControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    var dataController: CommentsDataController!
    var style: Style!
    
    var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    let commentSizingCell = CommentCell()
    var cellHeightCache = [NSIndexPath:CGFloat]()
    let ageFormatter = ThingAgeFormatter()

    deinit {
        tableView.delegate = nil
        tableView.dataSource = nil
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
    // MARK: - UIViewController
    
    override func loadView() {
        tableView = UITableView()
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = style.redditOrangeColor
        refreshControl.addTarget(self, action: Selector("pullToRefreshValueChanged:"), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .None
        tableView.backgroundColor = style.lightColor
        tableView.registerClass(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MoreCell")
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("contentSizeCategoryDidChangeNotification:"),
            name: UIContentSizeCategoryDidChangeNotification,
            object: nil
        )
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !dataController.isLoaded {
            dataController.loadComments()
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        cellHeightCache.removeAll(keepCapacity: true)
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

    func contentSizeCategoryDidChangeNotification(notification: NSNotification) {
        style.linkCellFontsDidChange()
        cellHeightCache.removeAll(keepCapacity: true)
        tableView.reloadData()
    }

    // MARK: - Refresh
    
    func pullToRefreshValueChanged(control: UIRefreshControl) {
//        dataController.refresh()
        cellHeightCache.removeAll(keepCapacity: true)
        tableView.reloadData()
    }

    
    // MARK: - CommentsDataControllerDelegate
    
    func commentsDataControllerDidBeginLoad(commentsDataController: CommentsDataController) {
        if dataController.count == 0 {
            if !refreshControl.refreshing {
                tableView.contentOffset = CGPoint(
                    x: tableView.contentOffset.x,
                    y: tableView.contentOffset.y - refreshControl.frame.height
                )
                refreshControl.beginRefreshing()
            }
        }
    }
    
    func commentsDataControllerDidEndLoad(commentsDataController: CommentsDataController) {
        if refreshControl.refreshing {
            refreshControl.endRefreshing()
        }
    }
    
    func commentsDataControllerDidLoadComments(commentsDataController: CommentsDataController) {
        cellHeightCache.removeAll(keepCapacity: true)
        tableView.reloadData()
    }
    
    func commentsDataController(commentsDataController: CommentsDataController, didFailWithReason reason: Error) {
        let alertView = UIAlertView(title: "Error", message: reason.description, delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
    }
    
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataController.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let comment = dataController.commentAtIndexPath(indexPath) {
            let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
            configureCommentCell(cell, comment: comment)
            return cell
        } else if let more = dataController.moreAtIndexPath(indexPath) {
            let cell = tableView.dequeueReusableCellWithIdentifier("MoreCell", forIndexPath: indexPath) as! UITableViewCell
            return cell
        } else {
            fatalError("Unhandled cell type")
        }
    }
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let height = cellHeightCache[indexPath] {
            return height
        } else {
            if let comment = dataController.commentAtIndexPath(indexPath) {
                let cell = commentSizingCell
                configureCommentCell(cell, comment: comment)
                let height = cell.sizeThatFits(CGSize(width: tableView.bounds.width, height: 10_000.00)).height
                cellHeightCache[indexPath] = height
                return height
            } else if let more = dataController.moreAtIndexPath(indexPath) {
                return 0.0
            } else {
                fatalError("Unhandled cell type")
            }
        }
    }
    
    // MARK: - CommentCell
    
    func configureCommentCell(cell: CommentCell, comment: Comment) {
        cell.backgroundColor = style.lightColor
        cell.authorLabel.backgroundColor = style.lightColor
        cell.authorLabel.textColor = style.redditUITextColor
        cell.authorLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        cell.bodyLabel.backgroundColor = style.lightColor
        cell.bodyLabel.textColor = style.darkColor
        cell.bodyLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        cell.separatorHeight = 1.0 / style.scale
        cell.insets = style.cellInsets
        cell.indentionView.backgroundColor = style.translucentDarkColor
        cell.separatorView.backgroundColor = style.translucentDarkColor
        cell.indentationLevel = comment.depth
        cell.authorLabel.text = authorForComment(comment)
        cell.bodyLabel.text = comment.body
    }
    
    func authorForComment(comment: Comment) -> String {
        if let age = ageFormatter.stringForDate(comment.createdUTC) {
            return "by \(comment.author) \(age)"
        } else {
            return "by \(comment.author)"
        }
    }
}
