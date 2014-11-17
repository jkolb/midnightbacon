//
//  ViewControllerPresenter.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/16/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

protocol ViewControllerPresenter : class {
    func presentViewController(viewController: UIViewController, animated: Bool, completion: (() -> ())?)
    func dismissViewControllerAnimated(animated: Bool, completion: (() -> ())?)
}

extension UIViewController : ViewControllerPresenter {
    
}
