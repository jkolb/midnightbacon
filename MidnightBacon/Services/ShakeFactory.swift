//
//  ShakeFactory.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 1/9/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit
import FieryCrucible

class ShakeFactory : DependencyFactory {
    var mainFactory: MainFactory!
    
    func debugController() -> DebugController {
        return shared(
            "debugController",
            factory: DebugController(),
            configure: { [unowned self] (instance) in
                instance.mainWindow = self.mainFactory.mainWindow()
                instance.oauth = self.mainFactory.oauth()
            }
        )
    }
    
    func shakeNavigationController() -> UINavigationController {
        return scoped(
            "shakeNavigationController",
            factory: UINavigationController(rootViewController: shakeRootViewController())
        )
    }
    
    func shakeRootViewController() -> UIViewController {
        return scoped(
            "shakeRootViewController",
            factory: MenuViewController(),
            configure: { [unowned self] (instance) in
                instance.style = self.mainFactory.sharedFactory().style()
                instance.menu = self.debugMenu()
                instance.title = "Debug Console"
                instance.navigationItem.rightBarButtonItem = self.shakeCloseButton()
            }
        )
    }
    
    func shakeCloseButton() -> UIBarButtonItem {
        return scoped(
            "shakeCloseButton",
            factory: UIBarButtonItem(barButtonSystemItem: .Done, target: debugController(), action: Selector("doneAction"))
        )
    }
    
    func debugMenu() -> Menu {
        return scoped(
            "debugMenu",
            factory: Menu(),
            configure: { [unowned self] (instance) in
                instance.addGroup(title: "OAuth", items: self.oAuthItems())
            }
        )
    }
    
    func oAuthItems() -> [Menu.Item] {
        return scoped(
            "oAuthItems",
            factory: [Menu.Item(title: "Trigger", action: debugController().triggerAction)]
        )
    }
}
