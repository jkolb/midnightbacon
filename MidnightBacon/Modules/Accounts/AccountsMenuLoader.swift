//
//  AccountsMenuLoader.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/6/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

class AccountsMenuLoader : MenuLoader {
    var secureStore: SecureStore!
    var insecureStore: InsecureStore!
    var actionController: AccountsActionController!
    
    init() { }
    
    func loadMenu() -> Promise<Menu> {
        return secureStore.findUsernames().when(self, { (controller, usernames) -> Result<Menu> in
            return .Success(controller.buildMenu(usernames))
        })
    }
    
    func buildMenu(usernames: [String]) -> Menu {
        let menu = Menu()
        
        if let username = insecureStore.lastAuthenticatedUsername {
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
            self.actionController.addAccount()
        }
    }
    
    func registerAccount() -> Menu.Item {
        return Menu.Item(title: "Register New Account") { [weak self] in
            
        }
    }
}
