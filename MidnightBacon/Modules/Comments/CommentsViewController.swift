//
//  CommentsViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 3/23/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

class CommentsViewController : UIViewController, CommentsDataControllerDelegate, ListViewDataSource {
    var dataController: CommentsDataController!
    var style: Style!
    
    var listView: ListView!
    var commentSizingCell: CommentCell!
    
    
    // MARK: - UIViewController
    
    override func loadView() {
        listView = ListView()
        view = listView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listView.backgroundColor = style.lightColor
        listView.dataSource = self
        listView.registerClass(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        listView.registerClass(ListViewCell.self, forCellReuseIdentifier: "MoreCell")
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
        listView.reloadData()
    }
    
    func commentsDataController(commentsDataController: CommentsDataController, didFailWithReason reason: Error) {
        let alertView = UIAlertView(title: "Error", message: reason.description, delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
    }
    
    
    // MARK: - ListViewDataSource
    
    func numberOfItemsInListView(listView: ListView) -> Int {
        return dataController.count
    }
    
    func listView(listView: ListView, cellForItemAtIndex index: Int) -> ListViewCell {
        if let comment = dataController.commentAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) {
            let cell = listView.dequeueReusableCellWithIdentifier("CommentCell") as! CommentCell
            configureCommentCell(cell, comment: comment)
            return cell
        } else if let more = dataController.moreAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) {
            let cell = listView.dequeueReusableCellWithIdentifier("MoreCell") as! ListViewCell
            return cell
        } else {
            fatalError("Unhandled cell type")
        }
    }
    
    
    // MARK: - CommentCell
    
    func configureCommentCell(cell: CommentCell, comment: Comment) {
        style.applyTo(cell)
        cell.bodyLabel.text = comment.body
    }
}
