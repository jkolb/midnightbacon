//
//  ConfigureTabController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/29/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class ConfigureTabController : NSObject, TabController {
    var tabViewController: UIViewController
    
    override init() {
        tabViewController = UIViewController()
        super.init()
    }
}
