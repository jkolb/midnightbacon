//
//  AccountsFlow.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/6/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

protocol AccountsActions {
    func addAccount()
}

class AccountsFlow : NavigationFlow, AccountsActions, AddAccountFlowDelegate {
    var styleFactory: StyleFactory!
    var accountsFactory: AccountsFactory!
    var redditUserInteractor: RedditUserInteractor!
    
    var aboutUserPromise: Promise<Account>!
    var addAccountFlow: AddAccountFlow!
    
    override func viewControllerDidLoad() {
        push(accountsMenuViewController(), animated: false)
    }
    
    func accountsMenuViewController() -> MenuViewController {
        let viewController = LoadedMenuViewController(style: .Grouped)
        viewController.loader = accountsFactory.accountsMenuLoader(self)
        viewController.style = styleFactory.style()
        viewController.title = "Accounts"
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem.edit(target: self, action: Selector("editAccounts"))
        return viewController
    }

    func editAccounts() {
        redditUserInteractor = accountsFactory.redditUserInteractor()
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
        if addAccountFlow != nil { return }
        addAccountFlow = AddAccountFlow()
        addAccountFlow.styleFactory = styleFactory
        addAccountFlow.accountsFactory = accountsFactory
        addAccountFlow.delegate = self
        
        start(addAccountFlow)
    }
    
    func addAccountFlowDidCancel(addAccountFlow: AddAccountFlow) {
        addAccountFlow.stopAnimated(true) { [weak self] in
            if let strongSelf = self {
                strongSelf.addAccountFlow = nil
            }
        }
    }
    
    func addAccountFlowDidComplete(addAccountFlow: AddAccountFlow) {
        addAccountFlow.stopAnimated(true) { [weak self] in
            if let strongSelf = self {
                strongSelf.addAccountFlow = nil
            }
        }
    }
}
