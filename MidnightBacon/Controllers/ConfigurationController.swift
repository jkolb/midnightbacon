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
    var onDone: (() -> ())?
    
    init() {
    }
    
    func rootViewController() -> UIViewController {
        let viewController = LoadedMenuViewController(style: .Grouped)
        viewController.title = "Configuration"
        viewController.loader = self
        viewController.navigationItem.leftBarButtonItem = doneBarButtonItem()
        return viewController
    }
    
    func loadMenu() -> Promise<Menu> {
        let secureStore = UIApplication.services.secureStore
        return secureStore.findUsernames().when({ (usernames) -> Result<Menu> in
            return .Success(MenuBuilder().accountMenu(usernames))
        })
    }
    
    func doneBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneAction")
    }
    
    @objc func doneAction() {
        if let doneHandler = onDone {
            doneHandler()
        }
    }
}
