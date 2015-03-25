//
//  AccountsFlowController.swift
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

class AccountsFlowController : NavigationFlowController, AccountsActions, AddAccountFlowControllerDelegate {
    weak var factory: MainFactory!
    var redditUserInteractor: RedditUserInteractor!
    
    var aboutUserPromise: Promise<Account>!
    var addAccountFlowController: AddAccountFlowController!
    
    override func viewControllerDidLoad() {
        pushViewController(accountsMenuViewController(), animated: false)
    }
    
    func accountsMenuViewController() -> MenuViewController {
        let viewController = LoadedMenuViewController(style: .Grouped)
        viewController.loader = factory.accountsMenuLoader(self)
        viewController.style = factory.style()
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
    
    func addAccountFlowControllerDidCancel(addAccountFlowController: AddAccountFlowController) {
        addAccountFlowController.stopAnimated(true) { [weak self] in
            if let strongSelf = self {
                strongSelf.addAccountFlowController = nil
            }
        }
    }
    
    func addAccountFlowControllerDidComplete(addAccountFlowController: AddAccountFlowController) {
        addAccountFlowController.stopAnimated(true) { [weak self] in
            if let strongSelf = self {
                strongSelf.addAccountFlowController = nil
            }
        }
    }
}
