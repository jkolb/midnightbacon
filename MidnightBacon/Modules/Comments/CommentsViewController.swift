//
//  CommentsViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 3/23/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

class CommentsViewController : UIViewController, CommentsDataControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    var dataController: CommentsDataController!
    var style: Style!
    
    var tableView: UITableView!
    let commentSizingCell = CommentCell()
    var cellHeightCache = [NSIndexPath:CGFloat]()
    
    
    // MARK: - UIViewController
    
    override func loadView() {
        tableView = UITableView()
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .None
        tableView.backgroundColor = style.lightColor
        tableView.registerClass(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MoreCell")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !dataController.isLoaded {
            dataController.loadComments()
        }
    }
    
    
    // MARK: - CommentsDataControllerDelegate
    
    func commentsDataControllerDidBeginLoad(commentsDataController: CommentsDataController) {
        
    }
    
    func commentsDataControllerDidEndLoad(commentsDataController: CommentsDataController) {
        
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
        style.applyTo(cell)
        cell.depthLabel.text = "\u{f3d3}\u{f3d3}"
        cell.bodyLabel.text = comment.body
    }
}
