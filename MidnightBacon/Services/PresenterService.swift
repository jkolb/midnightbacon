//
//  PresenterService.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/29/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

protocol Presenter {
    func presentViewController(viewController: UIViewController, animated: Bool, completion: (() -> ())?)
    func dismissViewControllerAnimated(animated: Bool, completion: (() -> ())?)
}

class PresenterService : Presenter {
    unowned var window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func presentViewController(viewController: UIViewController, animated: Bool, completion: (() -> ())?) {
        var presentingViewController: UIViewController = window.rootViewController!
        
        while presentingViewController.presentedViewController != nil {
            presentingViewController = presentingViewController.presentedViewController!
        }
        
        presentingViewController.presentViewController(viewController, animated: animated, completion: completion)
    }
    
    func dismissViewControllerAnimated(animated: Bool, completion: (() -> ())?) {
        var presentedViewController: UIViewController = window.rootViewController!
        
        while presentedViewController.presentedViewController != nil {
            presentedViewController = presentedViewController.presentedViewController!
        }
        
        presentedViewController.presentingViewController!.dismissViewControllerAnimated(animated, completion: completion)
    }
}
