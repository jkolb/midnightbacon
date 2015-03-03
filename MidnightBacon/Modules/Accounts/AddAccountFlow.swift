//
//  AddAccountFlow.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 3/2/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

@objc protocol AddAccountFlowDelegate {
    func addAccountFlowDidCancel(addAccountFlow: AddAccountFlow)
    func addAccountFlowDidComplete(addAccountFlow: AddAccountFlow)
}

class AddAccountFlow : NavigationFlow, LoginViewControllerDelegate {
    var styleFactory: StyleFactory!
    var accountsFactory: AccountsFactory!
    var delegate: AddAccountFlowDelegate!

    var addAccountInteractor: AddAccountInteractor!
    
    func addAccountViewController() -> LoginViewController {
        let viewController = LoginViewController(style: .Grouped)
        viewController.style = styleFactory.style()
        viewController.delegate = self
        viewController.title = "Add Account"
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.cancel(target: addAccountViewController(), action: Selector("cancel"))
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem.done(target: addAccountViewController(), action: Selector("done"))
        viewController.navigationItem.rightBarButtonItem?.enabled = viewController.isDoneEnabled()
        return viewController
    }
    
    override func flowWillStart(animated: Bool) {
        addAccountInteractor = accountsFactory.addAccountInteractor()
    }
    
    func cancelFlow() {
        if let strongDelegate = delegate {
            strongDelegate.addAccountFlowDidCancel(self)
        }
    }
    
    func completeFlow() {
        if let strongDelegate = delegate {
            strongDelegate.addAccountFlowDidComplete(self)
        }
    }
    
    func loginViewControllerDidCancel(loginViewController: LoginViewController) {
        cancelFlow()
    }
    
    func loginViewController(loginViewController: LoginViewController, didFinishWithUsername username: String, password: String) {
        let credential = NSURLCredential(user: username, password: password, persistence: .None)
        addAccountInteractor.addCredential(credential) { [weak self] in
            if let strongSelf = self {
                strongSelf.completeFlow()
            }
        }
    }
    
    func loginViewController(loginViewController: LoginViewController, doneEnabled: Bool) {
        viewController.navigationItem.rightBarButtonItem?.enabled = doneEnabled
    }
}
