//
//  CommentsFlowController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 3/19/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

class CommentsFlowController : NavigationFlowController {
    var factory: MainFactory!
    var link: Link!
    
    override func viewControllerDidLoad() {
        super.viewControllerDidLoad()
        let rootViewController = factory.commentsViewController(link)
        rootViewController.navigationItem.leftBarButtonItem = UIBarButtonItem.cancel(target: self, action: Selector("cancelComments"))
        navigationController.pushViewController(rootViewController, animated: false)
    }
    
    func cancelComments() {
        navigationController.dismissViewControllerAnimated(true, completion: nil)
    }
}
