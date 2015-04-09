//
//  CommentsViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 3/23/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

class CommentsViewController : UIViewController, CommentsDataControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    var dataController: CommentsDataController!
    
    var tableView: UITableView!
    var commentSizingCell: CommentCell!
    
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: view.bounds, style: .Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 88;
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.registerClass(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MoreCell")
        view.addSubview(tableView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !dataController.isLoaded {
            dataController.loadComments()
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    
    // MARK: - CommentsDataControllerDelegate
    
    func commentsDataControllerDidBeginLoad(commentsDataController: CommentsDataController) {
        
    }
    
    func commentsDataControllerDidEndLoad(commentsDataController: CommentsDataController) {
        
    }
    
    func commentsDataControllerDidLoadComments(commentsDataController: CommentsDataController) {
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
            NSLog("before dequeue \(indexPath)")
            let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
            configureCommentCell(cell, comment: comment)
            NSLog("after dequeue dequeue \(indexPath)")
            return cell
        } else if let more = dataController.moreAtIndexPath(indexPath) {
            let cell = tableView.dequeueReusableCellWithIdentifier("MoreCell", forIndexPath: indexPath) as! UITableViewCell
            return cell
        } else {
            fatalError("Unhandled cell type")
        }
    }

    
    // MARK: - UITableViewDelegate
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if let comment = dataController.commentAtIndexPath(indexPath) {
//            configureCommentCell(commentSizingCell, comment: comment)
//            
//            let fitSize = CGSize(width: tableView.bounds.width, height: 10000.0)
//            let size = commentSizingCell.sizeThatFits(fitSize)
//            commentSizingCell = nil
//            return size.height
//        } else if let more = dataController.moreAtIndexPath(indexPath) {
//            return 0.0;
//        } else {
//            fatalError("Unhandled cell type")
//        }
//    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        return nil
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // If this isn't present the swipe doesn't work
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("will display \(indexPath)")
    }
    
    
    // MARK: - CommentCell
    
    func configureCommentCell(cell: CommentCell, comment: Comment) {
        cell.bodyLabel.text = comment.body
    }
}
