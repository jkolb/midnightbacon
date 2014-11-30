//
//  UIBarButtonItem+Factory.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/21/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    class func done(# target: AnyObject?, action: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .Done, target: target, action: action)
    }
    
    class func cancel(# target: AnyObject?, action: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .Cancel, target: target, action: action)
    }
}
