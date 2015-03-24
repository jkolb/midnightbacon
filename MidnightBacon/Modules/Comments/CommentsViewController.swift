//
//  CommentsViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 3/23/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

class CommentsViewController : UIViewController, CommentsDataControllerDelegate {
    var dataController: CommentsDataController!
    
    
    // MARK: - UIViewController
    
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
        
    }
    
    func commentsDataController(commentsDataController: CommentsDataController, didFailWithReason reason: Error) {
        
    }
}
