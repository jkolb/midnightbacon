//
//  NavigationFlowController.swift
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

public class NavigationFlowController : FlowController, UINavigationControllerDelegate {
    private weak var parentFlow: NavigationFlowController?
    private var childFlows: [NavigationFlowController] = []
    public var navigationController: UINavigationController!
    var isPushing = false
    var isPopping = false
    var isUpdating = false
    var pendingCompletion: (() -> ())?
    
    public func loadNavigationController() -> UINavigationController {
        return UINavigationController()
    }
    
    deinit {
        if navigationController != nil {
            navigationController.delegate = nil
        }
    }
    
    public override func loadViewController() {
        if let parent = parentFlow {
            navigationController = parent.navigationController
        } else {
            navigationController = loadNavigationController()
            navigationController.delegate = self
        }
        
        viewController = navigationController
    }

    public override func viewControllerWillUnload() {
        navigationController.delegate = nil
    }
    
    public override func viewControllerDidUnload() {
        navigationController = nil
    }

    public func pushFlow(navigationFlow: NavigationFlowController, animated: Bool = true, completion: (() -> ())? = nil) {
        assert(navigationFlow.parentFlow == nil, "Already pushed to a parent")
        assert(!isLoaded, "Flow already loaded")
        assert(!isStarting, "Flow is starting")
        assert(!isStopping, "Flow is stopping")
        assert(!isPushing, "Flow already pushing")
        assert(!isPopping, "Flow is popping")
        assert(!isUpdating, "Flow is updating")
        navigationFlow.parentFlow = self
        childFlows.append(navigationFlow)
    }
    
    public func pushViewController(viewController: UIViewController, animated: Bool = true, completion: (() -> ())? = nil) {
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
    
    public func pop(animated: Bool = true, completion: (() -> ())? = nil) {
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
    
    public func update(viewControllers: [UIViewController]!, animated: Bool = true, completion: (() -> ())? = nil) {
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
    
    public func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        willShow(viewController, animated: animated)
    }
    
    public func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        isPushing = false
        isPopping = false
        isUpdating = false
        if let completion = pendingCompletion {
            completion()
        }
        didShow(viewController, animated: animated)
    }
    
    public func willShow(viewController: UIViewController, animated: Bool) {
        
    }
    
    public func didShow(viewController: UIViewController, animated: Bool) {
        
    }
}
