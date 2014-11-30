//
//  ApplicationController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/24/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

class ApplicationController : NSObject, Controller, ControllerPresenterService, UINavigationControllerDelegate {
    var services: Services!
    var subreddits = NSCache()
    var addUserPromise: Promise<Bool>?
    var lastAuthenticatedUsername: String? {
        return self.services.insecureStore.lastAuthenticatedUsername
    }
    var configurationController: ConfigurationController!
    var controllerStack = [Controller]()
    var addAccountFlow: Flow!
    
    init(services: Services) {
    }
    
    lazy var mainMenuController: MainMenuController = { [unowned self] in
        let controller = MainMenuController()
        controller.showSubredditAction = self.openLinks
        return controller
    }()
    lazy var navigationController: UINavigationController = { [unowned self] in
        let controller = UINavigationController(rootViewController: self.mainMenuController.viewController)
        controller.delegate = self
        return controller
    }()

    var viewController: UIViewController {
        return navigationController
    }

    func configureAction() -> TargetAction {
        return TargetAction { [unowned self] in
            self.configurationController = ConfigurationController()
            self.configurationController.triggerFlow = self.triggerFlow
            self.configurationController.doneAction = self.configurationDoneAction()
            self.presentController(self.configurationController, animated: true, completion: nil)
        }
    }
    
    func configurationDoneAction() -> TargetAction {
        return TargetAction { [unowned self] in
            self.dismissController(animated: true) {
                self.configurationController = nil
            }
        }
    }
    
    func openLinks(# title: String, path: String) {
//        pushController(linksController(path, refresh: false))
    }
    
    func showComments(link: Link) {
        let readCommentsController = ReadCommentsController()
        readCommentsController.link = link
        pushController(readCommentsController, animated: true)
    }
    
    func triggerFlow(name: String, completion: () -> ()) {
        if name == "AddAccount" {
            let addAccountFlow = AddAccountFlow()
            addAccountFlow.done = {
                completion()
                self.dismissController(animated: true, completion: nil)
            }
            addAccountFlow.cancel = { [unowned self] in
                self.dismissController(animated: true, completion: nil)
            }
            self.addAccountFlow = addAccountFlow
            presentController(addAccountFlow.startController, animated: true, completion: nil)
        }
    }
    
    func pushController(controller: Controller, animated: Bool = true) {
        controllerStack.append(controller)
        navigationController.pushViewController(controller.viewController, animated: animated)
    }
    
    func presentController(controller: Controller, animated: Bool, completion: (() -> ())?) {
        var presentingViewController: UIViewController = navigationController
        
        while presentingViewController.presentedViewController != nil {
            presentingViewController = presentingViewController.presentedViewController!
        }
        
        let containerController = UINavigationController(rootViewController: controller.viewController)
        presentingViewController.presentViewController(containerController, animated: animated, completion: completion)
    }
    
    func dismissController(# animated: Bool, completion: (() -> ())?) {
        var presentingViewController: UIViewController = navigationController
        
        while presentingViewController.presentedViewController != nil {
            presentingViewController = presentingViewController.presentedViewController!
        }
        
        presentingViewController.presentingViewController!.dismissViewControllerAnimated(true, completion: completion)
    }
    
    
    // MARK: - UINavigationControllerDelegate
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        if let lastController = controllerStack.last {
            if lastController.viewController != viewController {
                controllerStack.removeLast()
            }
        }
    }
}
