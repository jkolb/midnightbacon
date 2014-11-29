//
//  UISplitViewController+Creation.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/26/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

extension UISplitViewController {
    convenience init(master: UIViewController, detail: UIViewController) {
        self.init(nibName: nil, bundle: nil)
        viewControllers = [master, detail]
    }
}
