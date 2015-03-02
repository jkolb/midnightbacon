//
//  AccountsFlow.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/6/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

protocol AccountsActionController {
    func addAccount()
}

class AccountsFlow : NavigationFlow, AccountsActionController {
    var styleFactory: StyleFactory!
    var accountsFactory: AccountsFactory!
    var presenter: Presenter!
    var addAccountInteractor: AddAccountInteractor!
    var redditUserInteractor: RedditUserInteractor!
    
    var aboutUserPromise: Promise<Account>!
    
    override func viewControllerDidLoad() {
        push(accountsMenuViewController(), animated: false)
    }
    
    func accountsMenuViewController() -> MenuViewController {
        let viewController = LoadedMenuViewController(style: .Grouped)
        viewController.loader = accountsFactory.accountsMenuLoader()
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
        present(UINavigationController(rootViewController: accountsFactory.addAccountViewController()))
    }
    
    func onAddAccountCancel(viewController: LoginViewController) {
        dismiss()
    }

    func onAddAccountDone(viewController: LoginViewController, username: String, password: String) {
        addAccountInteractor = accountsFactory.addAccountInteractor()
        let credential = NSURLCredential(user: username, password: password, persistence: .None)
        addAccountInteractor.addCredential(credential) { [weak self] in
            if let strongSelf = self {
                strongSelf.dismiss()
                strongSelf.addAccountInteractor = nil
            }
        }
    }
    
    func onAddAccountDoneEnabled(viewController: LoginViewController, enabled: Bool) {
        viewController.navigationItem.rightBarButtonItem?.enabled = enabled
    }

    func present(viewController: UIViewController, animated: Bool = true, completion: (() -> ())? = nil) {
        presenter.presentViewController(viewController, animated: animated, completion: completion)
    }
    
    func dismiss(animated: Bool = true, completion: (() -> ())? = nil) {
        presenter.presentedViewController?.view.endEditing(true)
        presenter.dismissViewControllerAnimated(animated, completion: completion)
    }
}
