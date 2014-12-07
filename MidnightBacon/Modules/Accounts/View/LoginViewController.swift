//
//  LoginViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/17/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class LoginViewController : TableViewController, UITextFieldDelegate {
    var onCancel: ((viewController: LoginViewController) -> ())!
    var onDone: ((viewController: LoginViewController, username: String, password: String) -> ())!
    var onDoneEnabled: ((viewController: LoginViewController, enabled: Bool) -> ())!
    var username = ""
    var password = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "SubredditCell")
        tableView.backgroundColor = style.lightColor
        tableView.layoutMargins = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.separatorColor = style.mediumColor
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
    }
    
    func isUsername(indexPath: NSIndexPath) -> Bool {
        return indexPath.isEqual(NSIndexPath(forRow: 0, inSection: 0))
    }
    
    func isPassword(indexPath: NSIndexPath) -> Bool {
        return indexPath.isEqual(NSIndexPath(forRow: 1, inSection: 0))
    }
    
    func isUsername(textField: UITextField) -> Bool {
        return textField.tag == 1
    }
    
    func isPassword(textField: UITextField) -> Bool {
        return textField.tag == 2
    }
    
    func textFieldInView(view: UIView) -> UITextField? {
        if let textField = view as? UITextField {
            return textField
        }

        for subview in view.subviews {
            if let textField = textFieldInView(subview as UIView) {
                return textField
            }
        }
        
        return nil
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SubredditCell", forIndexPath: indexPath) as UITableViewCell
        let textFrame = UIEdgeInsetsInsetRect(cell.contentView.bounds, cell.layoutMargins)
        let textField = UITextField(frame: textFrame)
        textField.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        textField.autocapitalizationType = .None
        textField.autocorrectionType = .No
        textField.spellCheckingType = .No
        
        if isUsername(indexPath) {
            textField.text = username
            textField.placeholder = "Username"
            textField.returnKeyType = .Next
            textField.delegate = self
            textField.addTarget(self, action: Selector("usernameChanged:"), forControlEvents: .EditingChanged)
            textField.tag = 1
        } else if isPassword(indexPath) {
            textField.text = password
            textField.placeholder = "Password"
            textField.secureTextEntry = true
            textField.returnKeyType = .Go
            textField.delegate = self
            textField.addTarget(self, action: Selector("passwordChanged:"), forControlEvents: .EditingChanged)
            textField.tag = 2
        } else {
            fatalError("Unexpected indexPath")
        }
        
        cell.contentView.addSubview(textField)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if let textField = textFieldInView(cell) {
                textField.becomeFirstResponder()
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
//    func textFieldDidEndEditing(textField: UITextField) {
//        if isUsername(textField) {
//            username = textField.text
//        } else if isPassword(textField) {
//            password = textField.text
//        } else {
//            fatalError("Unexpected textField")
//        }
//    }
//    
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        return true
//    }
    
    func isDoneEnabled() -> Bool {
        return !username.isEmpty && !password.isEmpty
    }
    
    func usernameChanged(textField: UITextField) {
        username = textField.text
        onDoneEnabled(viewController: self, enabled: isDoneEnabled())
    }
    
    func passwordChanged(textField: UITextField) {
        password = textField.text
        onDoneEnabled(viewController: self, enabled: isDoneEnabled())
    }
    
    func cancel() {
        view.endEditing(true)
        onCancel(viewController: self)
    }
    
    func done() {
        view.endEditing(true)
        onDone(viewController: self, username: username, password: password)
    }
}
