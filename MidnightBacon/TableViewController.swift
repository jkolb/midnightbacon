//
//  TableViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/16/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class TableViewController : UITableViewController {
    var savedSelectedIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let style = UIApplication.services.style

        clearsSelectionOnViewWillAppear = false
        
        tableView.backgroundColor = style.lightColor
        tableView.layoutMargins = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.separatorColor = style.mediumColor
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        savedSelectedIndexPath = tableView.indexPathForSelectedRow()
        
        if let indexPath = savedSelectedIndexPath {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        savedSelectedIndexPath = nil
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let indexPath = savedSelectedIndexPath {
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition:.None)
        }
    }
}
