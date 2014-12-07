//
//  AddAccountController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/25/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

class AddAccountController {
    var cancel: (() -> ())!
    var done: (() -> ())!
    var interactor: AddAccountInteractor!
    
    init() {
    }
    
    lazy var loginViewController: LoginViewController = { [unowned self] in
        let viewController = LoginViewController(style: .Grouped)
        viewController.title = "Add Account"
//        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.cancel(self.cancelAction)
//        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem.done(self.doneAction)
        return viewController
    }()
    
    var viewController: UIViewController {
        return loginViewController
    }
    
    var credential: NSURLCredential {
        loginViewController.view.endEditing(true)
        let username = loginViewController.username
        let password = loginViewController.password
        return NSURLCredential(user: username, password: password, persistence: .None)
    }
    
    func addCredential(credential: NSURLCredential) {
        interactor.addCredential(credential) { [weak self] in
            if let strongSelf = self {
                strongSelf.done()
            }
        }
    }
}
