//
//  DebugFlowController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 1/12/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

enum DebugAction : String {
    case TriggerOAuth = "triggerOAuth"
}

class DebugFlowController : NavigationFlowController, OAuthFlowControllerDelegate {
    typealias ActionType = DebugAction
    weak var factory: MainFactory!
    
    override func viewControllerDidLoad() {
//        navigationController.pushViewController(debugMenuViewController(), animated: false)
    }
    
//    func debugMenuViewController() -> UIViewController {
//        let viewController = MenuViewController<DebugFlowController>(style: .Grouped)
//        viewController.style = factory.style()
//        viewController.menu = self.debugMenu()
//        viewController.title = "Debug Console"
//        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("doneAction"))
//        return viewController
//    }
    
    func doneAction() {
//        stop(presenter)
    }
    
    func debugMenu() -> Menu<DebugFlowController> {
        let menu = Menu<DebugFlowController>()
//        menu.addGroup(
//            title: "OAuth",
//            items: [
//                Menu.Item(title: "Trigger", action: .TriggerOAuth)
//            ]
//        )
        return menu
    }
    
    func triggerOAuth() {
        let flow = factory.oauthFlowController()
        flow.delegate = self
        presentAndStartFlow(flow)
    }
    
    // MARK: OAuthFlowDelegate
    
    func OAuthFlowControllerDidCancel(flowController: OAuthFlowController) {
        stopAnimated(true)
    }
    
    // MARK: - MenuDelegate
    
//    func menu(menu: Menu<Self>, didTriggerAction action: DebugAction, withValues values: [String:AnyObject]) {
//        switch action {
//        case .TriggerOAuth:
//            triggerOAuth()
//        }
////        if action == "triggerOAuth" {
////            triggerOAuth()
////        }
//    }
}
