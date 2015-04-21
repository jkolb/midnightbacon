//
//  MenuViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/16/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

class MenuViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    var menu: MenuDataSource?
    var tableView: UITableView!
    
    override func loadView() {
        tableView = UITableView(frame: CGRect.zeroRect, style: .Grouped)
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MenuCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow() {
            tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return menu?.numberOfGroups() ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu?.numberOfItemsInGroup(section) ?? 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return menu?.titleForGroup(section) ?? ""
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = menu?.titleForItemAtIndexPath(indexPath)
        
        if let type = menu?.typeForItemAtIndexPath(indexPath) {
            switch type {
            case .Navigation:
                cell.accessoryType = .DisclosureIndicator
            case .Selection:
                if menu?.isSelectedItemAtIndexPath(indexPath) ?? false {
                    cell.accessoryType = .Checkmark
                } else {
                    cell.accessoryType = .None
                }
            case .Action:
                cell.accessoryType = .None
            }
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        menu?.sendEventForItemAtIndexPath(indexPath)
        menu?.selectItemAtIndexPath(indexPath)
        
        if let type = menu?.typeForItemAtIndexPath(indexPath) {
            if type != .Navigation {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
    }
    
    func reloadMenu(menu: MenuDataSource) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            let sections = NSIndexSet(indexesInRange: NSRange(location: 0, length: menu.numberOfGroups()))
            
            self.tableView.beginUpdates()
            self.tableView.insertSections(sections, withRowAnimation: .Fade)
            self.menu = menu
            self.tableView.endUpdates()
        }
        
        let sections = NSIndexSet(indexesInRange: NSRange(location: 0, length: self.menu?.numberOfGroups() ?? 0))
        
        tableView.beginUpdates()
        tableView.deleteSections(sections, withRowAnimation: .Fade)
        self.menu = nil
        tableView.endUpdates()
        
        CATransaction.commit()
    }
}
