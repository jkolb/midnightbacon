//
//  DebugFlowController.swift
//  MidnightBacon
//
// Copyright (c) 2015 Justin Kolb - http://franticapparatus.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
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
