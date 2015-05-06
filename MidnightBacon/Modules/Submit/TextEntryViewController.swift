//
//  TextEntryViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 5/6/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit
import Common

class TextEntryViewController : UIViewController {
    var style: Style!
    var textView: UITextView!
    
    deinit {
        textView.delegate = nil
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func loadView() {
        textView = UITextView()
        view = textView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        textView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        textView.textColor = style.redditUITextColor
        textView.keyboardType = .Default
        textView.autocapitalizationType = .None
        textView.autocorrectionType = .No
        textView.spellCheckingType = .No
        textView.enablesReturnKeyAutomatically = false
//        textView.text = form.titleField.value

        registerForKeyboardNotifications()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.becomeFirstResponder()
    }
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardDidShowNotification:",
            name: UIKeyboardDidShowNotification,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardWillHideNotification:",
            name: UIKeyboardWillHideNotification,
            object: nil
        )
    }
    
    func keyboardDidShowNotification(notification: NSNotification) {
        let userInfo = notification.userInfo ?? [:]
        
        if let rectValue = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
            let keyboardSize = rectValue.CGRectValue().size
            var contentInset = textView.contentInset
            contentInset.bottom = keyboardSize.height
            textView.contentInset = contentInset
            textView.scrollIndicatorInsets = contentInset
        }
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        var contentInset = textView.contentInset
        contentInset.bottom = 0.0
        textView.contentInset = contentInset
        textView.scrollIndicatorInsets = contentInset
    }
}

extension TextEntryViewController : UITextViewDelegate {
    
}
