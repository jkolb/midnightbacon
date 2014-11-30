//
//  LoginService.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/23/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

@objc
class LoginService : AuthenticationService {
    var presenter: Presenter

    var loginViewController: LoginViewController!
    var credentialPromise: Promise<NSURLCredential>!

    init(presenter: Presenter) {
        self.presenter = presenter
    }
    
    func authenticate() -> Promise<NSURLCredential> {
        if let viewController = loginViewController {
            return credentialPromise
        } else {
            loginViewController = createViewController()
            presenter.presentViewController(loginViewController, animated: true, completion: nil)
            credentialPromise = Promise<NSURLCredential>()
            return credentialPromise
        }
    }
    
    func cancel() {
        presenter.dismissViewControllerAnimated(true) { [unowned self] in
            self.credentialPromise.reject(Error(message: "Cancelled"))
        }
    }
    
    func done() {
        let credential = self.credential
        presenter.dismissViewControllerAnimated(true) { [unowned self] in
            self.credentialPromise.fulfill(credential)
        }
    }

    func createViewController() -> LoginViewController {
        let viewController = LoginViewController(style: .Grouped)
        viewController.title = "Login"
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.cancel(target: self, action: Selector("cancel"))
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem.done(target: self, action: Selector("done"))
        return viewController
    }
    
    var credential: NSURLCredential {
        loginViewController.view.endEditing(true)
        let username = loginViewController.username
        let password = loginViewController.password
        return NSURLCredential(user: username, password: password, persistence: .None)
    }
}
