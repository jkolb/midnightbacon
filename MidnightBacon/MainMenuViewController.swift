//
//  MainMenuViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/14/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

class MainMenuViewController: UITableViewController, UIActionSheetDelegate {
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
    
    var menu: Menu!
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
