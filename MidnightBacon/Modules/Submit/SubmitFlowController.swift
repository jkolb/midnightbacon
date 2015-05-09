//
//  SubmitFlowController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/23/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit
import Common

enum SubmitFlowControllerAction {
    case Cancelled
    case Submitted
}

protocol SubmitFlowControllerDelegate : class {
    func submitFlowController(submitFlowController: SubmitFlowController, didTriggerAction action: SubmitFlowControllerAction)
}

class SubmitFlowController : NavigationFlowController {
    weak var factory: MainFactory!
    var subreddit: String?
    weak var delegate: SubmitFlowControllerDelegate?
    let dataController = SubmitDataController()
    
    private var submitViewController: SubmitViewController!
    private var textEntryViewController: TextEntryViewController!
    
    override func viewControllerDidLoad() {
        submitViewController = buildSubmitViewController()
        submitViewController.delegate = self
        submitViewController.navigationItem.leftBarButtonItem = UIBarButtonItem.cancel(target: self, action: Selector("cancelFlow"))
        submitViewController.navigationItem.rightBarButtonItem = UIBarButtonItem.submit(target: self, action: Selector("submitPost"))
        if let barButtonItem = submitViewController.navigationItem.rightBarButtonItem {
            barButtonItem.enabled = false
        }
        if let title = subreddit {
            submitViewController.title = "Submit to \(title)"
        } else {
            submitViewController.title = "Submit Post"
        }
        pushViewController(submitViewController, animated: false)
    }
    
    // MARK: - Actions
    
    func cancelFlow() {
        submitViewController.view.endEditing(true)
        delegate?.submitFlowController(self, didTriggerAction: .Cancelled)
    }
    
    func submitPost() {
        submitViewController.view.endEditing(true)
        
        submitViewController.navigationItem.rightBarButtonItem?.enabled = false
        submitViewController.view.userInteractionEnabled = false
        
        dataController.sendSubmitForm(submitViewController.form) { [weak self] (error) in
            if let strongSelf = self {
                strongSelf.submitViewController.navigationItem.rightBarButtonItem?.enabled = false
                strongSelf.submitViewController.view.userInteractionEnabled = false
                
                if let error = error {
                    let alertView = UIAlertView(title: "Error", message: error.description, delegate: nil, cancelButtonTitle: "OK")
                    alertView.show()
                } else {
                    strongSelf.delegate?.submitFlowController(strongSelf, didTriggerAction: .Submitted)
                }
            }
        }
    }
    
    // MARK: - View Controller Builders
    
    func buildSubmitViewController() -> SubmitViewController {
        let viewController = SubmitViewController(style: .Plain)
        viewController.style = factory.style()
        return viewController
    }
    
    func clearBackButtonTitle(viewController: UIViewController) {
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    override func willShow(viewController: UIViewController, animated: Bool) {
        clearBackButtonTitle(viewController)
    }
}

extension SubmitFlowController : SubmitViewControllerDelegate {
    func submitViewController(submitViewController: SubmitViewController, updatedCanSubmit: Bool) {
        if let barButtonItem = submitViewController.navigationItem.rightBarButtonItem {
            barButtonItem.enabled = updatedCanSubmit
        }
    }
    
    func sumbitViewController(submitViewController: SubmitViewController, willEditLongTextField longTextField: SubmitLongTextField) {
        textEntryViewController = TextEntryViewController()
        textEntryViewController.title = "Enter Text"
        textEntryViewController.style = submitViewController.style
        textEntryViewController.longTextField = longTextField
        textEntryViewController.navigationItem.leftBarButtonItem = UIBarButtonItem.cancel(target: self, action: "cancelEnteringText")
        textEntryViewController.navigationItem.rightBarButtonItem = UIBarButtonItem.done(target: self, action: "doneEnteringText")
        let navigationController = UINavigationController(rootViewController: textEntryViewController)
        self.navigationController.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func cancelEnteringText() {
        textEntryViewController.view.endEditing(true)
        navigationController.dismissViewControllerAnimated(true) { [weak self] in
            if let strongSelf = self {
                strongSelf.textEntryViewController = nil
            }
        }
    }
    
    func doneEnteringText() {
        textEntryViewController.view.endEditing(true)
        submitViewController.refreshSelfTextField()
        navigationController.dismissViewControllerAnimated(true) { [weak self] in
            if let strongSelf = self {
                strongSelf.textEntryViewController = nil
            }
        }
    }
}
