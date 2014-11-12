//
//  LoginViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/17/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class LoginViewController : UITableViewController, UITextFieldDelegate {
    let style = GlobalStyle()
    var username = ""
    var password = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearsSelectionOnViewWillAppear = true
        
        tableView.estimatedRowHeight = 50.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "SubredditCell")
        tableView.backgroundColor = style.lightColor
        tableView.layoutMargins = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.separatorColor = style.mediumColor
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
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
        
        switch indexPath.row {
        case 0:
            textField.text = username
            textField.placeholder = "Username"
            textField.returnKeyType = .Next
            textField.delegate = self
        case 1:
            textField.text = password
            textField.placeholder = "Password"
            textField.secureTextEntry = true
            textField.returnKeyType = .Go
            textField.delegate = self
        default:
            fatalError("Unexpected row")
        }
        
        cell.contentView.addSubview(textField)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.secureTextEntry {
            password = textField.text
        } else {
            username = textField.text
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
}
