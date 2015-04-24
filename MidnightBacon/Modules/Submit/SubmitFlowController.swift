//
//  SubmitFlowController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/23/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

protocol SubmitFlowControllerDelegate : class {
    func submitFlowControllerDidCancel(submitFlowController: SubmitFlowController)
}

class SubmitFlowController : NavigationFlowController {
    weak var factory: MainFactory!
    var subreddit: String?
    weak var delegate: SubmitFlowControllerDelegate?
    
    override func viewControllerDidLoad() {
        let viewController = buildSubmitViewController()
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.cancel(target: self, action: Selector("cancelFlow"))
        if let title = subreddit {
            viewController.title = "Submit to \(title)"
        } else {
            viewController.title = "Submit Post"
        }
        pushViewController(viewController, animated: false)
    }
    
    // MARK: - Actions
    
    func cancelFlow() {
        delegate?.submitFlowControllerDidCancel(self)
    }
    
    // MARK: - View Controller Builders
    
    func buildSubmitViewController() -> SubmitViewController {
        let viewController = SubmitViewController(style: .Plain)
        viewController.style = factory.style()
        return viewController
    }
}
