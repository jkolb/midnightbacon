//
//  Presenter.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 5/6/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

public protocol Presenter : class {
    var presentedViewController: UIViewController? { get }
    var presentingViewController: UIViewController? { get }
    func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
    func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?)
}
