//
//  ConfigurationController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

class ConfigurationController : Controller, MenuLoader {
    var doneAction: TargetAction!
    
    init() {
    }
    
    lazy var loadedMenuViewController: LoadedMenuViewController = { [unowned self] in
        let viewController = LoadedMenuViewController(style: .Grouped)
        viewController.title = "Configuration"
        viewController.loader = self
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.done(self.doneAction)
        return viewController
    }()
    
    var viewController: UIViewController {
        return loadedMenuViewController
    }
    
    func loadMenu() -> Promise<Menu> {
        let secureStore = UIApplication.services.secureStore
        return secureStore.findUsernames().when({ (usernames) -> Result<Menu> in
            return .Success(MenuBuilder().accountMenu(usernames))
        })
    }
}
