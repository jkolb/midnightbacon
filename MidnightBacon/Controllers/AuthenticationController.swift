//
//  AuthenticationController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/16/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

@objc class AuthenticationController {
    weak var presenter: ViewControllerPresenter?
    var credentialPromise: Promise<NSURLCredential>?
    var navigationController: UINavigationController?
    var loginViewController: LoginViewController?
    
    init(presenter: ViewControllerPresenter) {
        self.presenter = presenter
    }
    
    func authenticate() -> Promise<NSURLCredential> {
        if let promise = credentialPromise {
            return promise
        } else {
            present()
            credentialPromise = Promise<NSURLCredential>()
            return credentialPromise!
        }
    }

    func present() {
        loginViewController = createLoginViewController()
        navigationController = createNavigationController(rootViewController: loginViewController!)
        presenter?.presentViewController(navigationController!, animated: true, completion: nil)
    }
    
    func createNavigationController(# rootViewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        return navigationController
    }
    
    func createLoginViewController() -> LoginViewController {
        let viewController = LoginViewController(style: .Grouped)
        viewController.title = "Login"
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: Selector("cancelAuthentication"))
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("performAuthentication"))
        return viewController
    }
    
    func cancelAuthentication() {
        presenter?.dismissViewControllerAnimated(true) { [weak self] in
            if let strongSelf = self {
                if let promise = strongSelf.credentialPromise {
                    promise.reject(Error(message: "Cancelled"))
                    strongSelf.credentialPromise = nil
                }
            }
        }
    }
    
    func performAuthentication() {
        loginViewController!.view.endEditing(true)
        let username = loginViewController!.username
        let password = loginViewController!.password
        presenter?.dismissViewControllerAnimated(true) { [weak self] in
            if let strongSelf = self {
                if let promise = strongSelf.credentialPromise {
                    let credential = NSURLCredential(user: username, password: password, persistence: .None)
                    promise.fulfill(credential)
                    strongSelf.credentialPromise = nil
                }
            }
        }
    }
}
