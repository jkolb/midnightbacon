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

        UIApplication.services.style.applyTo(self)

        clearsSelectionOnViewWillAppear = false
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
