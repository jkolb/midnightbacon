//
//  SubmitViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/23/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit
import DrapierLayout

class SubmitViewController : TableViewController {
    var style: Style!
    let kindTitles = ["Link", "Text"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .None

        style.applyTo(self)
    }
    
    private func numberOfSegments() -> Int {
        return kindTitles.count
    }
    
    private func segmentTitleForIndex(index: Int) -> String {
        return kindTitles[index]
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        if indexPath.row == 0 {
            var items = [String]()
            for var i = 0; i < numberOfSegments(); ++i {
                items.append(segmentTitleForIndex(i))
            }
            let segmentedControl = UISegmentedControl(items: items)
            segmentedControl.selectedSegmentIndex = 0
            cell.contentView.addSubview(segmentedControl)
            
            segmentedControl.tintColor = style.redditUITextColor
            
            let insets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
            segmentedControl.frame = segmentedControl.layout(
                Left(equalTo: tableView.bounds.left(insets)),
                Right(equalTo: tableView.bounds.right(insets)),
                Top(equalTo: cell.contentView.bounds.top(insets)),
                Bottom(equalTo: cell.contentView.bounds.bottom(insets))
            )
        } else if indexPath.row == 1 {
            let textField = UITextField()
            textField.placeholder = "subreddit"
            cell.contentView.addSubview(textField)
            let insets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
            textField.frame = textField.layout(
                Left(equalTo: tableView.bounds.left(insets)),
                Right(equalTo: tableView.bounds.right(insets)),
                Top(equalTo: cell.contentView.bounds.top(insets)),
                Bottom(equalTo: cell.contentView.bounds.bottom(insets))
            )
        }
        
        return cell
    }
}
