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
    var services: Services!
    var triggerFlow: ((String, () -> ()) -> ())!
    var doneAction: TargetAction!
    
    init() {
    }
    
    lazy var loadedMenuViewController: LoadedMenuViewController = { [unowned self] in
        let viewController = LoadedMenuViewController(style: .Grouped)
        viewController.title = "Configuration"
        viewController.loader = self
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.cancel(self.doneAction)
        return viewController
    }()
    
    var viewController: UIViewController {
        return loadedMenuViewController
    }
    
    func loadMenu() -> Promise<Menu> {
        let secureStore = services.secureStore
        return secureStore.findUsernames().when(self, { (controller, usernames) -> Result<Menu> in
            return .Success(controller.buildMenu(usernames))
        })
    }
    
    func buildMenu(usernames: [String]) -> Menu {
        let menu = Menu()
        
        if let username = services.insecureStore.lastAuthenticatedUsername {
            menu.addGroup(
                title: username,
                items: [
                    logout(username),
                    preferences(username),
                ]
            )
        }
        
        var accountItems = Array<Menu.Item>()
        
        for username in usernames {
            accountItems.append(displayUser(username))
        }
        
        accountItems.append(addAccount())
        accountItems.append(registerAccount())
        
        menu.addGroup(
            title: "Accounts",
            items: accountItems
        )
        
        return menu
    }
    
    func logout(username: String) -> Menu.Item {
        return Menu.Item(title: "Logout") { [weak self] in
            
        }
    }
    
    func preferences(username: String) -> Menu.Item {
        return Menu.Item(title: "Preferences") { [weak self] in
            
        }
    }
    
    func displayUser(username: String) -> Menu.Item {
        return Menu.Item(title: username) { [weak self] in
            
        }
    }
    
    func addAccount() -> Menu.Item {
        return Menu.Item(title: "Add Existing Account") { [unowned self] in
            self.triggerFlow("AddAccount") { [weak self] in
                if let strongSelf = self {
                    strongSelf.loadedMenuViewController.reload()
                }
            }
        }
    }
    
    func registerAccount() -> Menu.Item {
        return Menu.Item(title: "Register New Account") { [weak self] in
            
        }
    }
}
