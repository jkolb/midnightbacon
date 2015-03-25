//
//  AddAccountFlowController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 3/2/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

@objc protocol AddAccountFlowControllerDelegate {
    func addAccountFlowControllerDidCancel(addAccountFlowController: AddAccountFlowController)
    func addAccountFlowControllerDidComplete(addAccountFlowController: AddAccountFlowController)
}

class AddAccountFlowController : NavigationFlowController, LoginViewControllerDelegate {
    weak var delegate: AddAccountFlowControllerDelegate!
    weak var factory: MainFactory!
    
    var addAccountInteractor: AddAccountInteractor!
    
    func addAccountViewController() -> LoginViewController {
        let viewController = LoginViewController(style: .Grouped)
        viewController.style = factory.style()
        viewController.delegate = self
        viewController.title = "Add Account"
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.cancel(target: addAccountViewController(), action: Selector("cancel"))
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem.done(target: addAccountViewController(), action: Selector("done"))
        viewController.navigationItem.rightBarButtonItem?.enabled = viewController.isDoneEnabled()
        return viewController
    }
    
    override func flowWillStart(animated: Bool) {
        addAccountInteractor = factory.addAccountInteractor()
    }
    
    func cancelFlow() {
        if let strongDelegate = delegate {
            strongDelegate.addAccountFlowControllerDidCancel(self)
        }
    }
    
    func completeFlow() {
        if let strongDelegate = delegate {
            strongDelegate.addAccountFlowControllerDidComplete(self)
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
