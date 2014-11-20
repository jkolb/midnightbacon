//
//  MenuViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/14/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

class MenuViewController : TableViewController {
    var promise: Promise<Menu>?
    var promiseFactory: (() -> Promise<Menu>)!
    var menu = Menu()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 50.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MenuCell")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if promise == nil && promiseFactory != nil {
            loadMenu()
        } else if (menu.count == 0) {
            fatalError("Empty menu")
        }
    }
    
    func loadMenu() {
        promise = promiseFactory().when(self, { (context, menu) -> () in
            context.menu = menu
            context.tableView.reloadData()
        }).finally(self, { (context) in
            context.promise = nil
        })
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
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel.text = menu[indexPath].title
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        menu[indexPath].action()
    }
}
