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
    weak var delegate: AddAccountFlowControllerDelegate?
    weak var factory: MainFactory?
    
    var addAccountViewController: LoginViewController!
    var addAccountInteractor: AddAccountInteractor!
    
    func buildAddAccountViewController() -> LoginViewController {
        let viewController = LoginViewController(style: .Grouped)
        viewController.style = factory?.style()
        viewController.delegate = self
        viewController.title = "Add Account"
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.cancel(target: self, action: Selector("cancelFlow"))
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem.done(target: self, action: Selector("completeFlow"))
        return viewController
    }
    
    override func viewControllerDidLoad() {
        super.viewControllerDidLoad()
        
        addAccountViewController = buildAddAccountViewController()
        addAccountViewController.navigationItem.rightBarButtonItem?.enabled = isDoneEnabled()
        navigationController.viewControllers = [addAccountViewController]
    }
    
    override func flowWillStart(animated: Bool) {
        addAccountInteractor = factory?.addAccountInteractor()
    }
    
    func cancelFlow() {
        if isStopping {
            return
        }
        
        delegate?.addAccountFlowControllerDidCancel(self)
    }
    
    func completeFlow() {
        if isStopping {
            return
        }
        
        addAccountViewController.view.endEditing(true)
        let credential = NSURLCredential(
            user: addAccountViewController.username,
            password: addAccountViewController.password,
            persistence: .None
        )
        addAccountInteractor.addCredential(credential) { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.addAccountFlowControllerDidComplete(strongSelf)
            }
        }
    }
    
    func isDoneEnabled() -> Bool {
        return !addAccountViewController.username.isEmpty && !addAccountViewController.password.isEmpty
    }
    
    func loginViewControllerFormChanged(loginViewController: LoginViewController) {
        viewController.navigationItem.rightBarButtonItem?.enabled = isDoneEnabled()
    }
}
