//
//  SubmitViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/23/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit
import DrapierLayout

protocol SubmitViewControllerDelegate : class {
    func submitViewController(submitViewController: SubmitViewController, canSubmit: Bool)
}

class SubmitViewController : TableViewController {
    weak var delegate: SubmitViewControllerDelegate?
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
        
        registerForKeyboardNotifications()
    }
    
    deinit {
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
            cell.textField.delegate = self
            cell.textField.tag = indexPath.row + 1
            cell.textField.addTarget(self, action: "editingChangedForTextField:", forControlEvents: .EditingChanged)
            
            if textField == form.subredditField {
                cell.textField.placeholder = "subreddit"
                cell.textField.keyboardType = .Default
                cell.textField.autocapitalizationType = .None
                cell.textField.autocorrectionType = .No
                cell.textField.spellCheckingType = .No
                cell.textField.enablesReturnKeyAutomatically = false
            } else if textField == form.titleField {
                cell.textField.placeholder = "title"
                cell.textField.keyboardType = .Default
                cell.textField.autocapitalizationType = .None
                cell.textField.autocorrectionType = .No
                cell.textField.spellCheckingType = .No
                cell.textField.enablesReturnKeyAutomatically = false
            }
            
            cell.textField.clearButtonMode = .WhileEditing
            cell.separatorHeight = 1.0 / style.scale
            cell.separatorView.backgroundColor = style.translucentDarkColor
            
            return cell
        case let textField as SubmitURLField:
            let cell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell", forIndexPath: indexPath) as! TextFieldTableViewCell
            cell.textField.delegate = self
            cell.textField.tag = indexPath.row + 1
            cell.textField.addTarget(self, action: "editingChangedForTextField:", forControlEvents: .EditingChanged)
            
            if textField == form.urlField {
                cell.textField.placeholder = "URL"
                cell.textField.keyboardType = .URL
                cell.textField.autocapitalizationType = .None
                cell.textField.autocorrectionType = .No
                cell.textField.spellCheckingType = .No
                cell.textField.enablesReturnKeyAutomatically = false
            }
            cell.textField.clearButtonMode = .WhileEditing
            cell.separatorHeight = 1.0 / style.scale
            cell.separatorView.backgroundColor = style.translucentDarkColor
            
            return cell
        case let switchField as SubmitBoolField:
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchTableViewCell
            cell.switchControl.addTarget(self, action: "sendRepliesValueChangedForSwitchControl:", forControlEvents: .ValueChanged)
            
            cell.titleLabel.text = "Send replies to my inbox"
            cell.separatorHeight = 1.0 / style.scale
            cell.separatorView.backgroundColor = style.translucentDarkColor
            
            return cell
        default:
            fatalError("Unexpected field \(field)")
        }
    }
    
    func sendRepliesValueChangedForSwitchControl(switchControl: UISwitch) {
        view.endEditing(true)
        println("switch \(switchControl.on)")
    }
    
    func editingChangedForTextField(textField: UITextField) {
        let indexPath = NSIndexPath(forRow: textField.tag - 1, inSection: 0)
        let field = form[indexPath.row]

        if let stringField = field as? SubmitTextField {
            stringField.value = textField.text
        } else if let urlField = field as? SubmitURLField {
            urlField.stringValue = textField.text
        }
        
        delegate?.submitViewController(self, canSubmit: form.isValid())
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
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? SwitchTableViewCell {
                cell.switchControl.setOn(!cell.switchControl.on, animated: true)
                sendRepliesValueChangedForSwitchControl(cell.switchControl)
            }
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

extension SubmitViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let nextIndexPath = NSIndexPath(forRow: textField.tag, inSection: 0)
        if let cell = tableView.cellForRowAtIndexPath(nextIndexPath) as? TextFieldTableViewCell {
            cell.textField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
