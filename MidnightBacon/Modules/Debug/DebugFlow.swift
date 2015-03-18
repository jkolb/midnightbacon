//
//  DebugFlow.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 1/12/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

class DebugFlow : NavigationFlow, OAuthFlowDelegate {
    weak var factory: MainFactory!
    
    override func viewControllerDidLoad() {
        navigationController.pushViewController(debugMenuViewController(), animated: false)
    }
    
    func debugMenuViewController() -> UIViewController {
        let viewController = MenuViewController()
        viewController.style = factory.style()
        viewController.menu = self.debugMenu()
        viewController.title = "Debug Console"
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("doneAction"))
        return viewController
    }
    
    func doneAction() {
//        stop(presenter)
    }
    
    func debugMenu() -> Menu {
        let menu = Menu()
        menu.addGroup(
            title: "OAuth",
            items: [
                Menu.Item(title: "Trigger", action: triggerOAuth)
            ]
        )
        return menu
    }
    
    func triggerOAuth() {
        let flow = factory.oauthFlow()
        flow.delegate = self
        presentAndStartFlow(flow)
    }
    
    // MARK: OAuthFlowDelegate
    
    func OAuthFlowDidCancel(flow: OAuthFlow) {
        stopAnimated(true)
    }
}
