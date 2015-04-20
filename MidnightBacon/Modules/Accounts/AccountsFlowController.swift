//
//  AccountsFlowController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/6/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

enum AccountAction {
    case AddAccount
    case Logout
}

class AccountsFlowController : NavigationFlowController, OAuthFlowControllerDelegate {
    weak var factory: MainFactory!
    var oauthService: OAuthService!
    var redditUserInteractor: RedditUserInteractor!
    var menuPromise: Promise<Menu<AccountAction>>?
    
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
            strongSelf.accountsMenuViewController.menu = menu
            if strongSelf.accountsMenuViewController.isViewLoaded() {
                strongSelf.accountsMenuViewController.tableView.reloadData()
            }
        })
    }
    
    func buildAccountsMenuViewController() -> MenuViewController {
        let viewController = MenuViewController()
        viewController.title = "Accounts"
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem.edit(target: self, action: Selector("editAccounts"))
        return viewController
    }

    func editAccounts() {
        redditUserInteractor = factory.redditUserInteractor()
        aboutUserPromise = redditUserInteractor.apiMe().then { (account) in
            /*
            let modhash: String
            let linkKarma: Int
            let commentKarma: Int
            let created: NSDate
            let createdUTC: NSDate
            let hasMail: Bool
            let hasModMail: Bool
            let hasVerifiedEmail: Bool
            let hideFromRobots: Bool
            let isFriend: Bool
            let isMod: Bool
            let over18: Bool
            let isGold: Bool
            let goldCreddits: Int
            let goldExpiration: NSDate?
             */
            println(account.linkKarma)
            println(account.commentKarma)
            println(account.hasMail)
            println(account.created)
            println(account.createdUTC)
        }
    }
    
    func addAccount() {
        if addAccountFlowController != nil { return }
        addAccountFlowController = factory.addAccountFlowController()
        addAccountFlowController.delegate = self
        
        presentAndStartFlow(addAccountFlowController)
    }
    
    func logout() {
        oauthService.logout()
        reloadMenu()
    }
    
    // MARK: - OAuthFlowControllerDelegate
    
    func oauthFlowControllerDidCancel(oauthFlowController: OAuthFlowController) {
        addAccountFlowController.stopAnimated(true) { [weak self] in
            if let strongSelf = self {
                strongSelf.addAccountFlowController = nil
                strongSelf.reloadMenu()
            }
        }
    }
    
    func oauthFlowController(oauthFlowController: OAuthFlowController, didCompleteWithResponse response: OAuthAuthorizeResponse) {
        addAccountFlowController.stopAnimated(true) { [weak self] in
            if let strongSelf = self {
                strongSelf.addAccountFlowController = nil
                println(response)
            }
        }
    }
    
    func loadMenu(# secureStore: SecureStore, insecureStore: InsecureStore) -> Promise<Menu<AccountAction>> {
        return secureStore.findUsernames().then(self, { (controller, usernames) -> Result<Menu<AccountAction>> in
            return Result(controller.buildMenu(insecureStore, usernames: usernames))
        })
    }
    
    func buildMenu(insecureStore: InsecureStore, usernames: [String]) -> Menu<AccountAction> {
        let menu = Menu<AccountAction>()
        
        if let username = insecureStore.lastAuthenticatedUsername {
            menu.addGroup(username)
            menu.addItem("Logout", action: .Logout)
            menu.addItem("Preferences", action: .AddAccount)
        }
        
        menu.addGroup("Accounts")
        for username in usernames { menu.addItem(username, action: .AddAccount) }
        menu.addItem("Add Existing Account", action: .AddAccount)
        menu.addItem("Register New Account", action: .AddAccount)
    
        menu.actionHandler = handleAccountAction
        
        return menu
    }

    func handleAccountAction(action: AccountAction) {
        switch action {
        case .AddAccount:
            addAccount()
        case .Logout:
            logout()
        }
    }
}
