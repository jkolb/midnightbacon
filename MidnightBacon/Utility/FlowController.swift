//
//  FlowController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 2/28/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

class FlowController : NSObject, Presenter {
    var _viewController: UIViewController!
    var isStarted = false
    var isStarting = false
    var isStopping = false
    
    var isLoaded: Bool {
        return _viewController != nil
    }
    
    var viewController: UIViewController! {
        get {
            if !isLoaded {
                loadViewController()
                viewControllerDidLoad()
            }
            return _viewController
        }
        set {
            if newValue == nil {
                assert(!isStarted, "viewController is started")
                _viewController = nil
                viewControllerDidUnload()
            } else {
                assert(!isLoaded, "viewController is already loaded")
                _viewController = newValue
            }
        }
    }
    
    var presentingViewController: UIViewController? {
        var presentingViewController: UIViewController = self.viewController
        
        while presentingViewController.presentedViewController != nil {
            presentingViewController = presentingViewController.presentedViewController!
        }
        
        return presentingViewController
    }
    
    func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        presentingViewController?.presentViewController(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    var presentedViewController: UIViewController? {
        var presentedViewController: UIViewController = self.viewController
        
        while presentedViewController.presentedViewController != nil {
            presentedViewController = presentedViewController.presentedViewController!
        }
        
        return presentedViewController
    }
    
    func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        presentedViewController?.presentingViewController!.dismissViewControllerAnimated(flag, completion: completion)
    }
    
    var canStart: Bool {
        return !isStarting && !isStarted && !isStopping
    }

    func start() -> UIViewController {
        assert(!isStarting, "Flow already starting")
        assert(!isStarted, "Flow already started")
        assert(!isStopping, "Flow is stopping")
        let viewController = self.viewController
        isStarting = true
        flowWillStart(false)
        isStarting = false
        isStarted = true
        flowDidStart(false)
        return viewController
    }
    
    func stop() {
        assert(!isStopping, "Flow already stopping")
        assert(isStarted, "Flow already stopped")
        assert(!isStarting, "Flow is starting")
        isStopping = true
        flowWillStop(false)
        isStopping = false
        isStarted = false
        viewController = nil
        flowDidStop(false)
    }
    
    func start(window: UIWindow) {
        assert(!isStarting, "Flow already starting")
        assert(!isStarted, "Flow already started")
        assert(!isStopping, "Flow is stopping")
        window.rootViewController = self.viewController
        isStarting = true
        flowWillStart(false)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("windowDidBecomeVisibleNotification:"), name: UIWindowDidBecomeVisibleNotification, object: window)
        window.makeKeyAndVisible()
    }
    
    func windowDidBecomeVisibleNotification(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIWindowDidBecomeVisibleNotification, object: notification.object)
        isStarting = false
        isStarted = true
        flowDidStart(false)
    }

    func presentAndStartFlow(flow: FlowController, animated: Bool = true, completion: (() -> ())? = nil) {
        assert(!flow.isStarting, "Flow already starting")
        assert(!flow.isStarted, "Flow already started")
        assert(!flow.isStopping, "Flow is stopping")
        let viewController = flow.viewController
        flow.isStarting = true
        flow.flowWillStart(animated)
        presentViewController(viewController, animated: animated) { [weak flow] in
            if let strongFlow = flow {
                strongFlow.isStarting = false
                strongFlow.isStarted = true
                if let block = completion {
                    block()
                }
                strongFlow.flowDidStart(animated)
            }
        }
    }
    
    var canStop: Bool {
        return !isStopping && isStarted && !isStarting
    }
    
    func stopAnimated(animated: Bool, completion: (() -> ())? = nil) {
        assert(!isStopping, "Flow already stopping")
        assert(isStarted, "Flow already stopped")
        assert(!isStarting, "Flow is starting")
        isStopping = true
        flowWillStop(animated)
        dismissViewControllerAnimated(animated) { [weak self] in
            if let strongSelf = self {
                strongSelf.isStopping = false
                strongSelf.isStarted = false
                if let block = completion {
                    block()
                }
                strongSelf.viewControllerWillUnload()
                strongSelf.viewController = nil
                strongSelf.viewControllerDidUnload()
                strongSelf.flowDidStop(animated)
            }
        }
    }
    
    func loadViewController() {
        viewController = UIViewController()
    }
    
    func viewControllerDidLoad() {
        
    }
    
    func viewControllerWillUnload() {
        
    }
    
    func viewControllerDidUnload() {
        
    }
    
    func flowWillStart(animated: Bool) {
        
    }
    
    func flowDidStart(animated: Bool) {
        
    }
    
    func flowWillStop(animated: Bool) {
        
    }
    
    func flowDidStop(animated: Bool) {
        
    }
}
