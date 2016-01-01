//
//  AccountsFlowController.swift
//  MidnightBacon
//
// Copyright (c) 2015 Justin Kolb - http://franticapparatus.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import UIKit
import FranticApparatus
import Reddit
import Common

enum AccountMenuEvent {
    case AddAccount
    case LurkerMode
    case SwitchToUsername(String)
    case Unimplemented
}

class AccountsFlowController : NavigationFlowController, OAuthFlowControllerDelegate {
    weak var factory: MainFactory!
    var oauthService: OAuthService!
    var menuPromise: Promise<Menu<AccountMenuEvent>>?
    
    var aboutUserPromise: Promise<Account>!
    var accountsMenuViewController: MenuViewController!
    var addAccountFlowController: OAuthFlowController!
    
    override func viewControllerDidLoad() {
        accountsMenuViewController = buildAccountsMenuViewController()
        pushViewController(accountsMenuViewController, animated: false)
    }
    
    override func flowDidStart(animated: Bool) {
        super.flowDidStart(animated)
        
        reloadMenu()
    }

    func reloadMenu() {
        menuPromise = loadMenu(secureStore: factory.secureStore(), insecureStore: factory.insecureStore()).then(self, { (strongSelf, menu) -> () in
            if strongSelf.accountsMenuViewController.isViewLoaded() {
                strongSelf.accountsMenuViewController.reloadMenu(menu)
            } else {
                strongSelf.accountsMenuViewController.menu = menu
            }
        }).finally(self, { (strongSelf) in
            strongSelf.menuPromise = nil
        })
    }
    
    func buildAccountsMenuViewController() -> MenuViewController {
        let viewController = MenuViewController()
        viewController.title = "Accounts"
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem.edit(target: self, action: Selector("editAccounts"))
        return viewController
    }

    func editAccounts() {
    }
    
    func addAccount() {
        if addAccountFlowController != nil { return }
        addAccountFlowController = factory.oauthFlowController()
        addAccountFlowController.delegate = self
        
        presentAndStartFlow(addAccountFlowController)
    }
    
    func lurkerMode() {
        oauthService.lurkerMode()
        reloadMenu()
    }
    
    func switchToUsername(username: String) {
        oauthService.switchToUsername(username)
        reloadMenu()
    }
    
    // MARK: - OAuthFlowControllerDelegate
    
    func oauthFlowControllerDidCancel(oauthFlowController: OAuthFlowController) {
        addAccountFlowController.stopAnimated(true) { [weak self] in
            if let strongSelf = self {
                strongSelf.addAccountFlowController = nil
            }
        }
    }
    
    func oauthFlowController(oauthFlowController: OAuthFlowController, didCompleteWithResponse response: OAuthAuthorizeResponse) {
        addAccountFlowController.stopAnimated(true) { [weak self] in
            if let strongSelf = self {
                strongSelf.addAccountFlowController = nil
                strongSelf.reloadMenu()
            }
        }
    }
    
    func loadMenu(secureStore secureStore: SecureStore, insecureStore: InsecureStore) -> Promise<Menu<AccountMenuEvent>> {
        return secureStore.findUsernames().then(self, { (controller, usernames) -> Promise<Menu<AccountMenuEvent>> in
            return controller.buildMenu(insecureStore, usernames: usernames)
        })
    }
    
    func buildMenu(insecureStore: InsecureStore, usernames: [String]) -> Menu<AccountMenuEvent> {
        let menu = Menu<AccountMenuEvent>()
        let lastAuthenticatedUsername = insecureStore.lastAuthenticatedUsername ?? ""
        
        if !lastAuthenticatedUsername.isEmpty {
            menu.addGroup(lastAuthenticatedUsername)
            menu.addActionItem("Logout", event: .LurkerMode)
            menu.addNavigationItem("Preferences", event: .Unimplemented)
        }
        
        menu.addGroup("Accounts")
        for username in usernames { menu.addSelectionItem(username, event: .SwitchToUsername(username), selected: username == lastAuthenticatedUsername) }
        menu.addSelectionItem("Lurker Mode", event: .LurkerMode, selected: lastAuthenticatedUsername.isEmpty)
        menu.addNavigationItem("Add Existing Account", event: .AddAccount)
    
        menu.eventHandler = handleAccountMenuEvent
        
        return menu
    }

    func handleAccountMenuEvent(event: AccountMenuEvent) {
        switch event {
        case .AddAccount:
            addAccount()
        case .LurkerMode:
            lurkerMode()
        case .SwitchToUsername(let username):
            switchToUsername(username)
        case .Unimplemented:
            UIAlertView(title: "Unimplemented", message: nil, delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
}
