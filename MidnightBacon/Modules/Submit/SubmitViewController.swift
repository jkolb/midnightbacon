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
    var form = SubmitForm.linkForm(nil)
    var header: SegmentedControlHeader!
    var textFieldSizingCell: TextFieldTableViewCell!
    var switchFieldSizingCell: SwitchTableViewCell!
    
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
        tableView.registerClass(SwitchTableViewCell.self, forCellReuseIdentifier: "SwitchCell")
        
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
        let field = form[indexPath.row]
        
        switch field {
        case let textField as SubmitTextField:
            let cell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell", forIndexPath: indexPath) as! TextFieldTableViewCell
            if textField == form.subredditField {
                cell.textField.placeholder = "subreddit"
            } else if textField == form.titleField {
                cell.textField.placeholder = "title"
            } else if textField == form.urlField {
                cell.textField.placeholder = "URL"
            }
            cell.textField.clearButtonMode = .WhileEditing
            cell.separatorHeight = 1.0 / style.scale
            cell.separatorView.backgroundColor = style.translucentDarkColor
            
            return cell
        case let textField as SubmitURLField:
            let cell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell", forIndexPath: indexPath) as! TextFieldTableViewCell
            if textField == form.subredditField {
                cell.textField.placeholder = "subreddit"
            } else if textField == form.titleField {
                cell.textField.placeholder = "title"
            } else if textField == form.urlField {
                cell.textField.placeholder = "URL"
            }
            cell.textField.clearButtonMode = .WhileEditing
            cell.separatorHeight = 1.0 / style.scale
            cell.separatorView.backgroundColor = style.translucentDarkColor
            
            return cell
        case let switchField as SubmitBoolField:
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchTableViewCell
            
            cell.titleLabel.text = "Send Replies"
            cell.separatorHeight = 1.0 / style.scale
            cell.separatorView.backgroundColor = style.translucentDarkColor
            
            return cell
        default:
            fatalError("Unexpected field \(field)")
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let field = form[indexPath.row]
        
        switch field {
        case let textField as SubmitTextField:
            if textFieldSizingCell == nil {
                textFieldSizingCell = TextFieldTableViewCell()
            }
            
            let sizeThatFits = textFieldSizingCell.sizeThatFits(CGSize(width: tableView.bounds.width, height: 10_000.00))
            
            return sizeThatFits.height
        case let textField as SubmitURLField:
            if textFieldSizingCell == nil {
                textFieldSizingCell = TextFieldTableViewCell()
            }
            
            let sizeThatFits = textFieldSizingCell.sizeThatFits(CGSize(width: tableView.bounds.width, height: 10_000.00))
            
            return sizeThatFits.height
        case let switchField as SubmitBoolField:
            if switchFieldSizingCell == nil {
                switchFieldSizingCell = SwitchTableViewCell()
            }
            
            let sizeThatFits = switchFieldSizingCell.sizeThatFits(CGSize(width: tableView.bounds.width, height: 10_000.00))
            
            return sizeThatFits.height
        default:
            fatalError("Unexpected field \(field)")
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let field = form[indexPath.row]
        
        switch field {
        case let textField as SubmitTextField:
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TextFieldTableViewCell {
                cell.textField.becomeFirstResponder()
            }
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        case let textField as SubmitURLField:
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TextFieldTableViewCell {
                cell.textField.becomeFirstResponder()
            }
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        case let switchField as SubmitBoolField:
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        default:
            fatalError("Unexpected field \(field)")
        }
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
