//
//  ConfigurationViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/14/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class ConfigurationViewController : UITableViewController {
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
    
    let sections: [String] = [
        "frantic_apparatus",
        "Accounts",
    ]
    let items: [[String]] = [
        ["Logout", "Preferences"],
        ["frantic_apparatus", "privatecage", "Add Account", "Register"],
    ]
    let style = Style()
    
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
        return sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let titles = items[section]
        return titles.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let titles = items[indexPath.section]
        let title = titles[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("SubredditCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel.text = title
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if sections[indexPath.section] == "Accounts" && items[indexPath.section][indexPath.item] == "Add Account" {
            let loginViewController = LoginViewController(style: .Grouped)
            loginViewController.title = "Login"
            loginViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel")
            let navigationController = UINavigationController(rootViewController: loginViewController)
            presentViewController(navigationController, animated: true, completion: nil)
        }
    }
    
    func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
