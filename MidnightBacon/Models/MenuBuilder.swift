//
//  MenuFactory.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class MenuBuilder {
    func accountMenu(usernames: [String]) -> Menu {
        let menu = Menu()
        
        if let username = UIApplication.services.insecureStore.lastAuthenticatedUsername {
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
        
//        accountItems.append(addAccount(reloadable))
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
    
//    func addAccount(reloadable: Reloadable) -> Menu.Item {
//        return Menu.Item(title: "Add Existing Account") { [weak self, weak reloadable] in
//            if let strongSelf = self {
//                if let strongReloadable = reloadable {
//                    strongSelf.controller.addUser(strongReloadable)
//                }
//            }
//        }
//    }
    
    func registerAccount() -> Menu.Item {
        return Menu.Item(title: "Register New Account") { [weak self] in
            
        }
    }
}
