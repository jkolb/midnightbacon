//
//  MessagesController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/6/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Common

public class MessagesFlowController : NavigationFlowController {
    private var messagesViewController: MessagesViewController!
    
    public override func viewControllerDidLoad() {
        messagesViewController = buildRootViewController()
        pushViewController(messagesViewController, animated: false)
    }

    private func buildRootViewController() -> MessagesViewController {
        let viewController = MessagesViewController()
        viewController.title = "Messages"
        return viewController
    }
}
