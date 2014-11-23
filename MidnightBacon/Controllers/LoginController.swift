//
//  LoginController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/16/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

class LoginController : AuthenticationController {
    var cancel: (() -> ())!
    var done: ((NSURLCredential) -> ())!

    init() {
    }
    
    lazy var loginViewController: LoginViewController = { [unowned self] in
        let viewController = LoginViewController(style: .Grouped)
        viewController.title = "Login"
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.cancel(self.cancelAction)
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem.done(self.doneAction)
        return viewController
    }()
    
    var viewController: UIViewController {
        return loginViewController
    }
    
    lazy var cancelAction: TargetAction = {
        return action(self) { (controller) in
            controller.cancel()
        }
    }()
    
    lazy var doneAction: TargetAction = {
        return action(self) { (controller) in
            controller.done(controller.credential)
        }
    }()
    
    var credential: NSURLCredential {
        loginViewController.view.endEditing(true)
        let username = loginViewController.username
        let password = loginViewController.password
        return NSURLCredential(user: username, password: password, persistence: .None)
    }
}
