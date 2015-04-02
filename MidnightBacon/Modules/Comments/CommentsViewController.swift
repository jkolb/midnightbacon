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
        tableView.registerClass(CommentCell.self, forCellReuseIdentifier: "CommentCell")
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
            let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
            configureCommentCell(cell, comment: comment)
            return cell
        }
        
        fatalError("Unhandled cell type")
//        return UITableViewCell()
    }

    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let comment = dataController.commentAtIndexPath(indexPath) {
            if commentSizingCell == nil {
                commentSizingCell = CommentCell(style: .Default, reuseIdentifier: "CommentSizingCell")
            }
            
            configureCommentCell(commentSizingCell, comment: comment)
            
//            let fitSize = CGSize(width: tableView.bounds.width, height: 10000.0)
//            let size = commentSizingCell.sizeThatFits(fitSize)
//            return size.height
            return 44.0;
        }
        
        fatalError("Unhandled cell type")
//        return 0.0
    }
    
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
    }
    
    
    // MARK: - CommentCell
    
    func configureCommentCell(cell: CommentCell, comment: Comment) {
        cell.textLabel?.text = comment.body
    }
}
