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

protocol DebugFlowControllerDelegate : class {
    func debugFlowControllerDidCancel(debugFlowController: DebugFlowController)
}

class DebugFlowController : NavigationFlowController, OAuthFlowControllerDelegate {
    weak var factory: MainFactory!
    weak var delegate: DebugFlowControllerDelegate!
    
    var oauthFlowController: OAuthFlowController!
    
    override func viewControllerDidLoad() {
        navigationController.pushViewController(debugMenuViewController(), animated: false)
    }
    
    func debugMenuViewController() -> UIViewController {
        let viewController = MenuViewController()
        viewController.menu = self.debugMenu()
        viewController.title = "Debug Console"
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("doneAction"))
        return viewController
    }
    
    func doneAction() {
        delegate.debugFlowControllerDidCancel(self)
    }
    
    func debugMenu() -> Menu<DebugAction> {
        let menu = Menu<DebugAction>()
        menu.addGroup("OAuth")
        menu.addItem("Trigger", action: .TriggerOAuth)
        menu.actionHandler = handleDebugAction
        return menu
    }
    
    func handleDebugAction(action: DebugAction) {
        switch action {
        case .TriggerOAuth:
            triggerOAuth()
        }
    }

    func triggerOAuth() {
        oauthFlowController = factory.oauthFlowController()
        oauthFlowController.delegate = self
        presentAndStartFlow(oauthFlowController)
    }
    
    // MARK: OAuthFlowDelegate
    
    func oauthFlowControllerDidCancel(oauthFlowController: OAuthFlowController) {
        oauthFlowController.stopAnimated(true) { [weak self] in
            self?.oauthFlowController = nil
        }
    }
    
    func oauthFlowController(oauthFlowController: OAuthFlowController, didCompleteWithResponse response: OAuthAuthorizeResponse) {
        oauthFlowController.stopAnimated(true) { [weak self] in
            self?.oauthFlowController = nil
            println(response)
        }
    }
}
