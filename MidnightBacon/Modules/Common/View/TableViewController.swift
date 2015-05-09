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
    
    deinit {
        tableView.delegate = nil
        tableView.dataSource = nil
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardDidShowNotification:",
            name: UIKeyboardDidShowNotification,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardWillHideNotification:",
            name: UIKeyboardWillHideNotification,
            object: nil
        )
    }
    
    func keyboardDidShowNotification(notification: NSNotification) {
        let userInfo = notification.userInfo ?? [:]
        
        if let rectValue = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
            let keyboardSize = rectValue.CGRectValue().size
            var contentInset = tableView.contentInset
            contentInset.bottom = keyboardSize.height
            tableView.contentInset = contentInset
            tableView.scrollIndicatorInsets = contentInset
        }
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        var contentInset = tableView.contentInset
        contentInset.bottom = 0.0
        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = contentInset
    }
    
    override func loadView() {
        tableView = UITableView(frame: CGRect.zeroRect, style: tableViewStyle)
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        registerForKeyboardNotifications()
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
