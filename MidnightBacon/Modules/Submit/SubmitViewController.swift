//
//  SubmitViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/23/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit
import DrapierLayout
import Common

protocol SubmitViewControllerDelegate : class {
    func submitViewController(submitViewController: SubmitViewController, updatedCanSubmit: Bool)
    func sumbitViewController(submitViewController: SubmitViewController, willEditLongTextField longTextField: SubmitLongTextField)
}

class SubmitViewController : TableViewController {
    weak var delegate: SubmitViewControllerDelegate?
    var style: Style!
    let kindTitles = ["Link", "Text"]
    var forms = [SubmitForm.linkForm(), SubmitForm.textForm()]
    var header: SegmentedControlHeader!
    var textFieldSizingCell: TextFieldTableViewCell!
    var textViewSizingCell: TextViewTableViewCell!
    var switchFieldSizingCell: SwitchTableViewCell!
    
    var formIndex = 0
    var form: SubmitForm {
        return forms[formIndex]
    }
    
    func refreshSelfTextField() {
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([indexPathOfFieldID(.Text)], withRowAnimation: .None)
        tableView.endUpdates()
        delegate?.submitViewController(self, updatedCanSubmit: form.isValid())
    }
    
    private func indexPathOfFieldID(id: SubmitFieldID) -> NSIndexPath {
        return NSIndexPath(forRow: form.indexOfFieldID(id), inSection: 0)
    }
    
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
        tableView.registerClass(TextViewTableViewCell.self, forCellReuseIdentifier: "TextViewCell")
        tableView.registerClass(TextFieldTableViewCell.self, forCellReuseIdentifier: "TextFieldCell")
        tableView.registerClass(SwitchTableViewCell.self, forCellReuseIdentifier: "SwitchCell")
        
        tableView.backgroundColor = style.lightColor
        tableView.layoutMargins = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.separatorColor = style.mediumColor
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
        
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
        formIndex = sender.selectedSegmentIndex
        tableView.reloadData()
        delegate?.submitViewController(self, updatedCanSubmit: form.isValid())
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
            cell.textField.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            cell.textField.textColor = style.redditUITextColor
            
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
            
            cell.textField.text = textField.value
            cell.textField.clearButtonMode = .WhileEditing
            cell.separatorHeight = 1.0 / style.scale
            cell.separatorView.backgroundColor = style.translucentDarkColor
            
            return cell
        case let longTextField as SubmitLongTextField:
            let cell = tableView.dequeueReusableCellWithIdentifier("TextViewCell", forIndexPath: indexPath) as! TextViewTableViewCell
            cell.textField.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            cell.textField.textColor = style.redditUITextColor
            cell.textField.userInteractionEnabled = false
            
            if longTextField == form.textField {
                cell.textField.placeholder = "text"
            }
            
            cell.textField.text = longTextField.value
            cell.separatorHeight = 1.0 / style.scale
            cell.separatorView.backgroundColor = style.translucentDarkColor
            
            return cell
        case let textField as SubmitURLField:
            let cell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell", forIndexPath: indexPath) as! TextFieldTableViewCell
            cell.textField.delegate = self
            cell.textField.tag = indexPath.row + 1
            cell.textField.addTarget(self, action: "editingChangedForTextField:", forControlEvents: .EditingChanged)
            cell.textField.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            cell.textField.textColor = style.redditUITextColor
            
            if textField == form.urlField {
                cell.textField.placeholder = "URL"
                cell.textField.keyboardType = .URL
                cell.textField.autocapitalizationType = .None
                cell.textField.autocorrectionType = .No
                cell.textField.spellCheckingType = .No
                cell.textField.enablesReturnKeyAutomatically = false
                cell.textField.text = form.urlField.stringValue
            }
            cell.textField.clearButtonMode = .WhileEditing
            cell.separatorHeight = 1.0 / style.scale
            cell.separatorView.backgroundColor = style.translucentDarkColor
            
            return cell
        case let switchField as SubmitBoolField:
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchTableViewCell
            cell.switchControl.addTarget(self, action: "sendRepliesValueChangedForSwitchControl:", forControlEvents: .ValueChanged)
            cell.switchControl.on = switchField.value ?? false
            
            cell.titleLabel.text = "Send replies to my inbox"
            cell.titleLabel.textColor = style.redditUITextColor
            cell.titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
            cell.switchControl.onTintColor = style.redditUITextColor
            cell.separatorHeight = 1.0 / style.scale
            cell.separatorView.backgroundColor = style.translucentDarkColor
            
            return cell
        default:
            fatalError("Unexpected field \(field)")
        }
    }
    
    func sendRepliesValueChangedForSwitchControl(switchControl: UISwitch) {
        view.endEditing(true)
        form.sendRepliesField.value = switchControl.on
    }
    
    func editingChangedForTextField(textField: UITextField) {
        let indexPath = NSIndexPath(forRow: textField.tag - 1, inSection: 0)
        let field = form[indexPath.row]

        if let stringField = field as? SubmitTextField {
            stringField.value = textField.text
        } else if let urlField = field as? SubmitURLField {
            urlField.stringValue = textField.text
        }
        
        delegate?.submitViewController(self, updatedCanSubmit: form.isValid())
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let field = form[indexPath.row]
        
        switch field {
        case let textField as SubmitTextField:
            if textFieldSizingCell == nil {
                textFieldSizingCell = TextFieldTableViewCell()
                textFieldSizingCell.textField.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            }
            
            let sizeThatFits = textFieldSizingCell.sizeThatFits(CGSize(width: tableView.bounds.width, height: 10_000.00))
            
            return sizeThatFits.height
        case let longTextField as SubmitLongTextField:
            if textViewSizingCell == nil {
                textViewSizingCell = TextViewTableViewCell()
                textViewSizingCell.textField.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            }
            
            let sizeThatFits = textViewSizingCell.sizeThatFits(CGSize(width: tableView.bounds.width, height: 10_000.00))
            
            return sizeThatFits.height
        case let textField as SubmitURLField:
            if textFieldSizingCell == nil {
                textFieldSizingCell = TextFieldTableViewCell()
                textFieldSizingCell.textField.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
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
        case let longTextField as SubmitLongTextField:
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TextViewTableViewCell {
                delegate?.sumbitViewController(self, willEditLongTextField: longTextField)
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
        return formIndex
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
