//
//  TableViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/16/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class TableViewController : UIViewController {
    var tableViewStyle: UITableViewStyle
    var tableView: UITableView!
    
    init(style: UITableViewStyle) {
        self.tableViewStyle = style
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        self.tableViewStyle = .Plain
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        tableView = UITableView(frame: CGRect.zeroRect, style: tableViewStyle)
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow() {
            tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
    }
}

extension TableViewController : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension TableViewController : UITableViewDelegate {
}
