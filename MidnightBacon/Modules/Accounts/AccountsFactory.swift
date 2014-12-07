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
                instance.presenter = self.sharedFactory.presenter()
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
            factory: LoadedMenuViewController(style: .Grouped),
            configure: { [unowned self] (instance) in
                instance.loader = self.accountsMenuLoader()
                instance.style = self.sharedFactory.style()
                instance.title = "Accounts"
                instance.tabBarItem = UITabBarItem(title: "Accounts", image: UIImage(named: "user"), tag: 0)
            }
        )
    }
    
    func accountsMenuLoader() -> MenuLoader {
        return unshared(
            "accountsMenuLoader",
            factory: AccountsMenuLoader(),
            configure: { [unowned self] (instance) in
                instance.secureStore = self.sharedFactory.secureStore()
                instance.insecureStore = self.sharedFactory.insecureStore()
                instance.actionController = self.accountsController()
            }
        )
    }
    
    func addAccountViewController() -> LoginViewController {
        return scoped(
            "addAccountViewController",
            factory: LoginViewController(style: .Grouped),
            configure: { [unowned self] (instance) in
                instance.style = self.sharedFactory.style()
                instance.onCancel = self.accountsController().onAddAccountCancel
                instance.onDone = self.accountsController().onAddAccountDone
                instance.onDoneEnabled = self.accountsController().onAddAccountDoneEnabled
                instance.title = "Add Account"
                instance.navigationItem.leftBarButtonItem = self.addAccountCancelBarButtonItem()
                instance.navigationItem.rightBarButtonItem = self.addAccountDoneBarButtonItem()
            }
        )
    }
    
    func addAccountCancelBarButtonItem() -> UIBarButtonItem {
        return scoped(
            "addAccountCancelBarButtonItem",
            factory: UIBarButtonItem.cancel(target: addAccountViewController(), action: Selector("cancel"))
        )
    }
    
    func addAccountDoneBarButtonItem() -> UIBarButtonItem {
        return scoped(
            "addAccountDoneBarButtonItem",
            factory: UIBarButtonItem.done(target: addAccountViewController(), action: Selector("done")),
            configure: { [unowned self] (instance) in
                instance.enabled = self.addAccountViewController().isDoneEnabled()
            }
        )
    }

    func addAccountInteractor() -> AddAccountInteractor {
        return scoped(
            "addAccountInteractor",
            factory: AddAccountInteractor(),
            configure: { [unowned self] (instance) in
                instance.gateway = self.sharedFactory.gateway()
                instance.secureStore = self.sharedFactory.secureStore()
            }
        )
    }
}
