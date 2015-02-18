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
    var presenter: Presenter!
    var sharedFactory: SharedFactory!
    
    var fulfillPromise: ((NSURLCredential) -> ())!
    var rejectPromise: ((Error) -> ())!
    var credentialPromise: Promise<NSURLCredential>!

    init() { }
    
    func authenticate() -> Promise<NSURLCredential> {
        if let promise = credentialPromise {
            return promise
        } else {
            present(sharedFactory.loginViewController())
            credentialPromise = Promise<NSURLCredential> { (fulfill, reject, isCancelled) in
                self.fulfillPromise = fulfill
                self.rejectPromise = reject
            }
            return credentialPromise
        }
    }
    
    func onCancel(viewController: LoginViewController) {
        dismiss(animated: true) { [unowned self] in
            self.rejectPromise(Error(message: "Cancelled"))
            self.credentialPromise = nil
        }
    }
    
    func onDone(viewController: LoginViewController, username: String, password: String) {
        dismiss(animated: true) { [unowned self] in
            let credential = NSURLCredential(user: username, password: password, persistence: .None)
            self.fulfillPromise(credential)
            self.credentialPromise = nil
        }
    }
    
    func onDoneEnabled(viewController: LoginViewController, enabled: Bool) {
        viewController.navigationItem.rightBarButtonItem?.enabled = enabled
    }
    
    func present(viewController: UIViewController, animated: Bool = true, completion: (() -> ())? = nil) {
        let navigationController = UINavigationController(rootViewController: viewController)
        presenter.presentViewController(navigationController, animated: animated, completion: completion)
    }
    
    func dismiss(animated: Bool = true, completion: (() -> ())? = nil) {
        presenter.presentedViewController.view.endEditing(true)
        presenter.dismissViewControllerAnimated(animated, completion: completion)
    }
}
