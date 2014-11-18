//
//  ConfigurationViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/14/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

class ConfigurationViewController : TableViewController, Reloadable {
    var menuBuilder: MenuBuilder!
    var redditSession: RedditSession!
    var secureStore: SecureStore!
    var insecureStore: InsecureStore!
    var usernamesPromise: Promise<[String]>?
    var menu: Menu!
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
            reload()
        }
    }
    
    func reload() {
        usernamesPromise = secureStore.findUsernames().when(self, { (strongSelf, usernames) -> () in
            strongSelf.refreshSections(usernames)
        }).finally(self, { (strongSelf) in
            strongSelf.usernamesPromise = nil
        })
    }
    
    func refreshSections(usernames: [String]) {
        menu = menuBuilder.accountMenu(self, lastAuthenticatedUsername: insecureStore.lastAuthenticatedUsername, usernames: usernames)
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return menu.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu[section].count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return menu[section].title
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SubredditCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel.text = menu[indexPath].title
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        menu[indexPath].action()
    }
}
