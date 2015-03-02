//
//  NavigationFlow.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 2/28/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

class NavigationFlow : Flow, UINavigationControllerDelegate {
    var navigationController: UINavigationController!
    var isPushing = false
    var isPopping = false
    var isUpdating = false
    var pendingCompletion: (() -> ())?
    
    func loadNavigationController() -> UINavigationController {
        return UINavigationController()
    }
    
    override func loadViewController() {
        navigationController = loadNavigationController()
        navigationController.delegate = self
        viewController = navigationController
    }

    override func viewControllerDidUnload() {
        navigationController = nil
    }
    
    func push(viewController: UIViewController, animated: Bool = true, completion: (() -> ())? = nil) {
        assert(isLoaded, "Flow not loaded")
        assert(!isStarting, "Flow is starting")
        assert(!isStopping, "Flow is stopping")
        assert(!isPushing, "Flow already pushing")
        assert(!isPopping, "Flow is popping")
        assert(!isUpdating, "Flow is updating")
        isPushing = true
        pendingCompletion = completion
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func pop(animated: Bool = true, completion: (() -> ())? = nil) {
        assert(isLoaded, "Flow not loaded")
        assert(!isStarting, "Flow is starting")
        assert(!isStopping, "Flow is stopping")
        assert(!isPopping, "Flow already popping")
        assert(!isPushing, "Flow is pushing")
        assert(!isUpdating, "Flow is updating")
        isPopping = true
        pendingCompletion = completion
        navigationController.popViewControllerAnimated(animated)
    }
    
    func update(viewControllers: [UIViewController]!, animated: Bool = true, completion: (() -> ())? = nil) {
        assert(isLoaded, "Flow not loaded")
        assert(!isStarting, "Flow is starting")
        assert(!isStopping, "Flow is stopping")
        assert(!isUpdating, "Flow already updating")
        assert(!isPopping, "Flow is popping")
        assert(!isPushing, "Flow is pushing")
        isUpdating = true
        pendingCompletion = completion
        navigationController.setViewControllers(viewControllers, animated: animated)
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        willShow(viewController, animated: animated)
    }
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        isPushing = false
        isPopping = false
        isUpdating = false
        if let completion = pendingCompletion {
            completion()
        }
        didShow(viewController, animated: animated)
    }
    
    func willShow(viewController: UIViewController, animated: Bool) {
        
    }
    
    func didShow(viewController: UIViewController, animated: Bool) {
        
    }
}
