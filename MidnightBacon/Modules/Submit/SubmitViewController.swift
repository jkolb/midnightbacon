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
    let kindTitles = ["Link", "Text", "Photo"]
    var form = SubmitForm()
    var header: SegmentedControlHeader!
    var textFieldSizingCell: TextFieldTableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        header = SegmentedControlHeader()
        header.delegate = self
        header.frame = CGRect(origin: CGPoint.zeroPoint, size: header.sizeThatFits(tableView.bounds.size))
        header.segmentedControl.tintColor = style.redditUITextColor
        header.backgroundColor = style.lightColor
        header.segmentedControl.addTarget(self, action: "segmentChanged:", forControlEvents: .ValueChanged)
        
        tableView.tableHeaderView = header
        tableView.separatorStyle = .None
        tableView.registerClass(TextFieldTableViewCell.self, forCellReuseIdentifier: "TextFieldCell")
        
        style.applyTo(self)
    }
    
    func segmentChanged(sender: UISegmentedControl) {
        println("selected: \(kindTitles[sender.selectedSegmentIndex])")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return form.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell", forIndexPath: indexPath) as! TextFieldTableViewCell
        let field = form[indexPath.row]
        
        if field == form.subredditField {
            cell.textField.placeholder = "subreddit"
        } else if field == form.titleField {
            cell.textField.placeholder = "title"
        } else if field == form.urlField {
            cell.textField.placeholder = "URL"
        }
        
        cell.textField.clearButtonMode = .WhileEditing
        cell.separatorHeight = 1.0 / style.scale
        cell.separatorView.backgroundColor = style.translucentDarkColor

        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if textFieldSizingCell == nil {
            textFieldSizingCell = TextFieldTableViewCell()
        }
        
        let sizeThatFits = textFieldSizingCell.sizeThatFits(CGSize(width: tableView.bounds.width, height: 10_000.00))
        
        return sizeThatFits.height
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TextFieldTableViewCell {
            cell.textField.becomeFirstResponder()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension SubmitViewController : SegmentedControlHeaderDelegate {
    func numberOfSegmentsInSegmentedControlHeader(segmentedControlHeader: SegmentedControlHeader) -> Int {
        return kindTitles.count
    }
    
    func selectedIndexOfSegmentedControlHeader(segmentedControlHeader: SegmentedControlHeader) -> Int {
        return 0
    }
    
    func segmentedControlHeader(segmentedControlHeader: SegmentedControlHeader, titleForSegmentAtIndex index: Int) -> String {
        return kindTitles[index]
    }
}
