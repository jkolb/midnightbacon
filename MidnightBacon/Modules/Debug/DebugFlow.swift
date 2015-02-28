//
//  DebugFlow.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 1/12/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

class DebugFlow : NSObject {
    var presenter: Presenter!
    var oauthFlow: OAuthFlow!
    var debugFactory: DebugFactory!
    var isPresented = false
    var isPresenting = false
    var isDismissing = false
    
    var canPresent: Bool {
        return !isPresenting && !isPresented && !isDismissing
    }
    
    func present(completion: (() -> ())? = nil) {
        assert(!isPresenting, "Flow already presenting")
        assert(!isPresented, "Flow already presented")
        assert(!isDismissing, "Flow is dismissing")
        isPresenting = true
        presenter.presentViewController(debugFactory.shakeNavigationController(), animated: true) { [weak self] in
            if let strongSelf = self {
                strongSelf.isPresenting = false
                strongSelf.isPresented = true
                if let block = completion {
                    block()
                }
            }
        }
    }
    
    var canDismiss: Bool {
        return !isDismissing && isPresented && !isPresenting
    }
    
    func dismiss(completion: (() -> ())? = nil) {
        assert(!isDismissing, "Flow already dismissing")
        assert(isPresented, "Flow already dismissed")
        assert(!isPresenting, "Flow is presenting")
        isDismissing = true
        presenter.dismissViewControllerAnimated(true) { [weak self] in
            if let strongSelf = self {
                strongSelf.isDismissing = false
                strongSelf.isPresented = false
                if let block = completion {
                    block()
                }
            }
        }
    }
    
    func doneAction() {
        dismiss()
    }
    
    func triggerOAuth() {
        oauthFlow.present()
    }
}
