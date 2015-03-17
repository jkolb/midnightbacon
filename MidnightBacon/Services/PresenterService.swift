//
//  PresenterService.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/29/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

protocol Presenter : class {
    var presentedViewController: UIViewController? { get }
    var presentingViewController: UIViewController? { get }
    func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
    func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?)
}

extension UIViewController : Presenter {
}

class PresenterService : Presenter {
    unowned var window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    var presentingViewController: UIViewController? {
        var presentingViewController: UIViewController = window.rootViewController!
        
        while presentingViewController.presentedViewController != nil {
            presentingViewController = presentingViewController.presentedViewController!
        }
        
        return presentingViewController
    }
    
    func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
//        presentingViewController.presentViewController(viewControllerToPresent, animated: flag, completion: completion)
    }

    var presentedViewController: UIViewController? {
        var presentedViewController: UIViewController = window.rootViewController!
        
        while presentedViewController.presentedViewController != nil {
            presentedViewController = presentedViewController.presentedViewController!
        }
        
        return presentedViewController
    }
    
    func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
//        presentedViewController.presentingViewController!.dismissViewControllerAnimated(flag, completion: completion)
    }
}
