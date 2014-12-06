//
//  AccountsController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/6/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

protocol AccountsActionController {
    func addAccount()
}

class AccountsController : NSObject, UINavigationControllerDelegate, AccountsActionController {
    var accountsFactory: AccountsFactory!
    var navigationController: UINavigationController!
    var presenter: Presenter!
    
    func addAccount() {
        present(UINavigationController(rootViewController: accountsFactory.addAccountViewController()))
    }
    
    func cancelAddAccount() {
        dismiss()
    }
    
    func completeAddAccount() {
        dismiss()
    }
    
    func present(viewController: UIViewController, animated: Bool = true, completion: (() -> ())? = nil) {
        presenter.presentViewController(viewController, animated: animated, completion: completion)
    }
    
    func dismiss(animated: Bool = true, completion: (() -> ())? = nil) {
        presenter.presentedViewController.view.endEditing(true)
        presenter.dismissViewControllerAnimated(animated, completion: completion)
    }
}
