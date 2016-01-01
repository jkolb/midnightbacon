//
//  SubmitFlowController.swift
//  MidnightBacon
//
// Copyright (c) 2015 Justin Kolb - http://franticapparatus.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import UIKit
import Common
import ModestProposal
import FranticApparatus

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
        dataController.delegate = self
        dataController.redditRequest = factory.redditRequest()
        dataController.oauthService = factory.oauthService()
        dataController.gateway = factory.gateway()

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
        
        dataController.sendSubmitForm(submitViewController.form)
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

extension SubmitFlowController : SubmitDataControllerDelegate {
    func submitDataControllerDidComplete(submitDataController: SubmitDataController) {
        self.submitViewController.navigationItem.rightBarButtonItem?.enabled = true
        self.submitViewController.view.userInteractionEnabled = true

        self.delegate?.submitFlowController(self, didTriggerAction: .Submitted)
    }
    
    func submitDataController(submitDataController: SubmitDataController, didFailWithError error: ErrorType) {
        self.submitViewController.navigationItem.rightBarButtonItem?.enabled = true
        self.submitViewController.view.userInteractionEnabled = true
        
        let alertView = UIAlertView(title: "Error", message: "\(error)", delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
    }
}
