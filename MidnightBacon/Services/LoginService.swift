//
//  LoginService.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/23/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

class LoginService : AuthenticationService {
    var presenterService: ControllerPresenterService!
    var controllerFactory: (() -> AuthenticationController)!

    var authenticationController: AuthenticationController?
    var credentialPromise: Promise<NSURLCredential>!

    init() {
    }
    
    func authenticate() -> Promise<NSURLCredential> {
        if let controller = authenticationController {
            return credentialPromise
        } else {
            authenticationController = createController()
            presentController(authenticationController!)
            credentialPromise = Promise<NSURLCredential>()
            return credentialPromise
        }
    }
    
    func cancel() {
        presenterService.dismissController(animated: true) { [unowned self] in
            if let promise = self.credentialPromise {
                promise.reject(Error(message: "Cancelled"))
                self.credentialPromise = nil
            }
        }
    }
    
    func done(credential: NSURLCredential) {
        presenterService.dismissController(animated: true) { [unowned self] in
            if let promise = self.credentialPromise {
                promise.fulfill(credential)
                self.credentialPromise = nil
            }
        }
    }

    func createController() -> AuthenticationController {
        var controller = controllerFactory()
        controller.cancel = cancel
        controller.done = done
        return controller
    }
    
    func presentController(controller: AuthenticationController) {
        presenterService.presentController(controller, animated: true, completion: nil)
    }
}
