//
//  DebugFlowController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 1/12/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit
import Reddit
import Common

enum DebugMenuEvent : String {
    case ClearKeychain = "clearKeychain"
    case ClearUserDefaults = "clearUserDefaults"
}

protocol DebugFlowControllerDelegate : class {
    func debugFlowControllerDidCancel(debugFlowController: DebugFlowController)
}

class DebugFlowController : NavigationFlowController {
    weak var factory: MainFactory!
    weak var delegate: DebugFlowControllerDelegate!
    
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
    
    func debugMenu() -> Menu<DebugMenuEvent> {
        let menu = Menu<DebugMenuEvent>()
        menu.addGroup("Keychain")
        menu.addActionItem("Clear", event: .ClearKeychain)
        menu.addGroup("User Defaults")
        menu.addActionItem("Clear", event: .ClearUserDefaults)
        menu.eventHandler = handleDebugMenuEvent
        return menu
    }
    
    func handleDebugMenuEvent(event: DebugMenuEvent) {
        switch event {
        case .ClearKeychain:
            clearKeychain()
        case .ClearUserDefaults:
            clearUserDefaults()
        }
    }
    
    func clearKeychain() {
        Keychain().clear()
    }

    func clearUserDefaults() {
        UserDefaultsStore().clear()
    }
}
