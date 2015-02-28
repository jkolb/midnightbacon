//
//  ModalFlow.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 2/28/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

class ModalFlow : NSObject {
    var presenter: Presenter!
    var isPresented = false
    var isPresenting = false
    var isDismissing = false
    
    var canPresent: Bool {
        return !isPresenting && !isPresented && !isDismissing
    }
    
    func present(animated: Bool = true, completion: (() -> ())? = nil) {
        assert(!isPresenting, "Flow already presenting")
        assert(!isPresented, "Flow already presented")
        assert(!isDismissing, "Flow is dismissing")
        isPresenting = true
        presenter.presentViewController(rootViewController(), animated: animated) { [weak self] in
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
    
    func dismiss(animated: Bool = true, completion: (() -> ())? = nil) {
        assert(!isDismissing, "Flow already dismissing")
        assert(isPresented, "Flow already dismissed")
        assert(!isPresenting, "Flow is presenting")
        isDismissing = true
        presenter.dismissViewControllerAnimated(animated) { [weak self] in
            if let strongSelf = self {
                strongSelf.isDismissing = false
                strongSelf.isPresented = false
                if let block = completion {
                    block()
                }
            }
        }
    }
    
    func rootViewController() -> UIViewController {
        fatalError("Must override in subclass")
    }
}
