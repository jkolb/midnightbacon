//
//  UIBarButtonItem+Factory.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/21/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    class func configure(action: TargetAction) -> UIBarButtonItem {
        return UIApplication.services.style.barButtonItem(
            title: NSLocalizedString("⚙", comment: "Configuration Bar Button Item Title"),
            tintColor: UIApplication.services.style.redditUITextColor,
            action: action
        )
    }
    
    class func messages(action: TargetAction) -> UIBarButtonItem {
        let style = UIApplication.services.style
        return UIApplication.services.style.barButtonItem(
            title: NSLocalizedString("✉︎", comment: "Messages Bar Button Item Title"),
            tintColor: style.redditOrangeRedColor,
            action: action
        )
    }
    
    class func noMessages(action: TargetAction) -> UIBarButtonItem {
        let style = UIApplication.services.style
        return UIApplication.services.style.barButtonItem(
            title: NSLocalizedString("✉︎", comment: "Messages Bar Button Item Title"),
            tintColor: style.redditUITextColor,
            action: action
        )
    }
    
    class func sort(action: TargetAction) -> UIBarButtonItem {
        let style = UIApplication.services.style
        return UIApplication.services.style.barButtonItem(
            title: NSLocalizedString("Sort", comment: "Sort Button Item Title"),
            tintColor: style.redditUITextColor,
            action: action
        )
    }
}
