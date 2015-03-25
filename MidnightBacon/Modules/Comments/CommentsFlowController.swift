//
//  CommentsFlowController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 3/19/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

class CommentsFlowController : NavigationFlowController {
    override func viewControllerDidLoad() {
        super.viewControllerDidLoad()
        
        navigationController.pushViewController(CommentsViewController(), animated: false)
    }
}
