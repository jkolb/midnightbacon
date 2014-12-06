//
//  PresenterService.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/29/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

protocol Presenter {
    var presentedViewController: UIViewController { get }
    func presentViewController(viewController: UIViewController, animated: Bool, completion: (() -> ())?)
    func dismissViewControllerAnimated(animated: Bool, completion: (() -> ())?)
}

class PresenterService : Presenter {
    unowned var window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    var presentingViewController: UIViewController {
        var presentingViewController: UIViewController = window.rootViewController!
        
        while presentingViewController.presentedViewController != nil {
            presentingViewController = presentingViewController.presentedViewController!
        }
        
        return presentingViewController
    }
    
    func presentViewController(viewController: UIViewController, animated: Bool, completion: (() -> ())?) {
        presentingViewController.presentViewController(viewController, animated: animated, completion: completion)
    }

    var presentedViewController: UIViewController {
        var presentedViewController: UIViewController = window.rootViewController!
        
        while presentedViewController.presentedViewController != nil {
            presentedViewController = presentedViewController.presentedViewController!
        }
        
        return presentedViewController
    }
    
    func dismissViewControllerAnimated(animated: Bool, completion: (() -> ())?) {
        presentedViewController.presentingViewController!.dismissViewControllerAnimated(animated, completion: completion)
    }
}
