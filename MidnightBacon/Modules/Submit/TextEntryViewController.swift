//
//  TextEntryViewController.swift
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

class TextEntryViewController : UIViewController {
    var style: Style!
    private var textView: UITextView!
    var longTextField: SubmitLongTextField!
    
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
        textView.text = longTextField.value
        
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
    func textViewDidEndEditing(textView: UITextView) {
        longTextField.value = textView.text
    }
}
