//
//  AccountsFactory.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/6/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FieryCrucible
import UIKit

class AccountsFactory : DependencyFactory {
    var sharedFactory: SharedFactory!
    
    func accountsController() -> AccountsController {
        return shared(
            "accountsController",
            factory: AccountsController(),
            configure: { [unowned self] (instance) in
                instance.accountsFactory = self
                instance.navigationController = self.tabNavigationController()
            }
        )
    }
    
    func tabNavigationController() -> UINavigationController {
        return scoped(
            "tabNavigationController",
            factory: UINavigationController(rootViewController: accountsMenuViewController()),
            configure: { [unowned self] (instance) in
                instance.delegate = self.accountsController()
            }
        )
    }
    
    func accountsMenuViewController() -> MenuViewController {
        return scoped(
            "accountsMenuViewController",
            factory: MenuViewController(style: .Grouped),
            configure: { [unowned self] (instance) in
                instance.menu = self.accountsMenuBuilder().build()
                instance.style = self.sharedFactory.style()
                instance.title = "Accounts"
                instance.tabBarItem = UITabBarItem(title: "Accounts", image: UIImage(named: "user"), tag: 0)
            }
        )
    }
    
    func accountsMenuBuilder() -> AccountsMenuBuilder {
        return unshared(
            "accountsMenuBuilder",
            factory: AccountsMenuBuilder(),
            configure: { [unowned self] (instance) in
                instance.actionController = self.accountsController()
            }
        )
    }
}
