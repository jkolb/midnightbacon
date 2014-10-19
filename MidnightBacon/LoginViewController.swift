//
//  LoginViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/17/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class LoginViewController : UITableViewController, UITextFieldDelegate {
    struct Style {
        let backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        let foregroundColor = UIColor(white: 0.04, alpha: 1.0)
        let separatorColor = UIColor(white: 0.04, alpha: 0.2)
        //        let backgroundColor = UIColor(white: 0.04, alpha: 1.0)
        //        let foregroundColor = UIColor(white: 0.96, alpha: 1.0)
        //        let separatorColor = UIColor(white: 0.96, alpha: 0.2)
        //        let upvoteColor = UIColor(red: 0.98, green: 0.28, blue: 0.12, alpha: 1.0)
        //        let downvoteColor = UIColor(red: 0.12, green: 0.28, blue: 0.98, alpha: 1.0)
        let upvoteColor = UIColor(red: 255.0/255.0, green: 139.0/255.0, blue: 96.0/255.0, alpha: 1.0) // ff8b60
        let downvoteColor = UIColor(red: 148.0/255.0, green: 148.0/255.0, blue: 255.0/255.0, alpha: 1.0) // 9494ff
    }
    let style = Style()
    var username = ""
    var password = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearsSelectionOnViewWillAppear = true
        
        tableView.estimatedRowHeight = 50.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "SubredditCell")
        tableView.backgroundColor = style.backgroundColor
        tableView.layoutMargins = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.separatorColor = style.separatorColor
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
        let textFrame = UIEdgeInsetsInsetRect(cell.contentView.bounds, cell.layoutMargins);
        let textField = UITextField(frame: textFrame)
        textField.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        
        switch indexPath.row {
        case 0:
            textField.text = username
            textField.placeholder = "Username"
            textField.returnKeyType = .Next
        case 1:
            textField.text = password;
            textField.placeholder = "Password"
            textField.secureTextEntry = true
            textField.returnKeyType = .Go
        default:
            fatalError("Unexpected row")
        }
        
        cell.contentView.addSubview(textField)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
}
