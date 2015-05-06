//
//  UIBarButtonItem+Factory.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/21/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    public class func edit(# target: AnyObject?, action: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .Edit, target: target, action: action)
    }
    
    public class func done(# target: AnyObject?, action: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .Done, target: target, action: action)
    }
    
    public class func cancel(# target: AnyObject?, action: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .Cancel, target: target, action: action)
    }
    
    public class func submit(# target: AnyObject?, action: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(title: "Submit", style: .Plain, target: target, action: action)
    }
    
    public class func compose(#style: Style, target: AnyObject?, action: Selector) -> UIBarButtonItem {
        let image = UIImage(named: "compose")!.tinted(style.redditUITextColor)
        return UIBarButtonItem(image: image, style: .Plain, target: target, action: action)
    }
}
