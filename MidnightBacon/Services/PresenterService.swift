//
//  PresenterService.swift
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
import Common

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
