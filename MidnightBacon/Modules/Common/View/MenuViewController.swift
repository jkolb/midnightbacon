//
//  MenuViewController.swift
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

class MenuViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    var menu: MenuDataSource?
    var tableView: UITableView!
    
    deinit {
        tableView.delegate = nil
        tableView.dataSource = nil
    }
    
    override func loadView() {
        tableView = UITableView(frame: CGRect.zero, style: .Grouped)
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
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
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
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath)
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
