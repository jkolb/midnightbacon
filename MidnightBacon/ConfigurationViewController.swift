//
//  ConfigurationViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/14/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

class ConfigurationViewController : TableViewController {
    var secureStore: SecureStore!
    var insecureStore: InsecureStore!
    var usernamesPromise: Promise<[String]>?
    var sections: [String] = []
    var items: [[String]] = []
    let style = GlobalStyle()
    
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if usernamesPromise == nil {
            usernamesPromise = secureStore.findUsernames().when(self, { (strongSelf, usernames) -> () in
                strongSelf.refreshSections(usernames)
            }).finally(self, { (strongSelf) in
                strongSelf.usernamesPromise = nil
            })
        }
    }
    
    func refreshSections(usernames: [String]) {
        sections = [String]()
        items = [[String]]()
        
        if let lastUsername = insecureStore.lastAuthenticatedUsername {
            sections.append(lastUsername)
            items.append(["Logout", "Preferences"])
        }
        
        var accountsItems = [String]()
        
        for username in usernames {
            accountsItems.append(username)
        }
        
        accountsItems.append("Add Account")
        accountsItems.append("Register")
        
        sections.append("Accounts")
        items.append(accountsItems)
        
        tableView.reloadData()
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
