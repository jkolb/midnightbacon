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
    func shakeNavigationController() -> UINavigationController {
        return scoped(
            "shakeNavigationController",
            factory: UINavigationController(rootViewController: shakeRootViewController())
        )
    }
    
    func shakeRootViewController() -> UIViewController {
        return scoped(
            "shakeRootViewController",
            factory: UIViewController(nibName: nil, bundle: nil),
            configure: { [unowned self] (instance) in
                instance.navigationItem.rightBarButtonItem = self.shakeCloseButton()
            }
        )
    }
    
    func shakeCloseButton() -> UIBarButtonItem {
        return scoped(
            "shakeCloseButton",
            factory: UIBarButtonItem(barButtonSystemItem: .Done, target: shakeRootViewController(), action: Selector(""))
        )
    }
}
