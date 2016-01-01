//
//  SubmitViewController.swift
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
import DrapierLayout
import Common
import Reddit

protocol SubmitViewControllerDelegate : class {
    func submitViewController(submitViewController: SubmitViewController, updatedCanSubmit: Bool)
    func sumbitViewController(submitViewController: SubmitViewController, willEditLongTextField longTextField: SubmitLongTextField)
}

class SubmitViewController : TableViewController {
    weak var delegate: SubmitViewControllerDelegate?
    var style: Style!
    let kinds = SubmitKind.allKinds()
    let kindTitles = ["Link", "Text"]
    var forms = [SubmitForm.linkForm(), SubmitForm.textForm()]
    var header: SegmentedControlHeader!
    var cellPresenters = [SubmitFieldID:TableCellPresenter]()

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
        if let index = form.indexOfFieldID(id) {
            return NSIndexPath(forRow: index, inSection: 0)
        } else {
            return NSIndexPath(forItem: NSNotFound, inSection: 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cellPresenters[.Title] = titlePresenter()
        cellPresenters[.Subreddit] = subredditPresenter()
        cellPresenters[.URL] = urlPresenter()
        cellPresenters[.Text] = textPresenter()
        cellPresenters[.SendReplies] = sendRepliesPresenter()
        
        header = SegmentedControlHeader()
        header.delegate = self
        header.frame = CGRect(origin: CGPoint.zero, size: header.sizeThatFits(tableView.bounds.size))
        header.segmentedControl.tintColor = style.redditUITextColor
        header.backgroundColor = style.lightColor
        header.segmentedControl.addTarget(self, action: "segmentChanged:", forControlEvents: .ValueChanged)
        
        tableView.tableHeaderView = header
        tableView.separatorStyle = .None
        
        for cellPresenter in cellPresenters.values {
            cellPresenter.registerCellClassForTableView(tableView)
        }
        
        tableView.backgroundColor = style.lightColor
        tableView.layoutMargins = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.separatorColor = style.mediumColor
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
    }
    
    func segmentChanged(sender: UISegmentedControl) {
        formIndex = sender.selectedSegmentIndex
        tableView.reloadData()
        delegate?.submitViewController(self, updatedCanSubmit: form.isValid())
    }
    
    private func cellPresenterForField(field: SubmitField) -> TableCellPresenter {
        if let cellPresenter = cellPresenters[field.id] {
            return cellPresenter
        } else {
            fatalError("Unexpected field \(field)")
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return form.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let field = form[indexPath.row]
        return cellPresenterForField(field).cellForRowInTableView(tableView, atIndexPath: indexPath, withValue: field)
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
        return cellPresenterForField(field).heightForRowInTableView(tableView, atIndexPath: indexPath, withValue: field)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let field = form[indexPath.row]
        cellPresenterForField(field).selectRowInTableView(tableView, atIndexPath: indexPath, withValue: field)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension SubmitViewController : SegmentedControlHeaderDelegate {
    func numberOfSegmentsInSegmentedControlHeader(segmentedControlHeader: SegmentedControlHeader) -> Int {
        return kinds.count
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
        if let cell = tableView.cellForRowAtIndexPath(nextIndexPath) as? TextFieldCell {
            cell.textField.becomeFirstResponder()
        } else if let cell = tableView.cellForRowAtIndexPath(nextIndexPath) as? URLFieldCell {
            cell.textField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

extension SubmitViewController {
    private func titlePresenter() -> TableViewCellPresenter<SubmitTextField, TextFieldCell, SubmitViewController> {
        let presenter = TableViewCellPresenter<SubmitTextField, TextFieldCell, SubmitViewController>(context: self, reuseIdentifier: SubmitFieldID.Title.rawValue)
        presenter.present = { (context, value, cell, indexPath) -> () in
            cell.textField.delegate = self
            cell.textField.tag = indexPath.row + 1
            cell.textField.addTarget(self, action: "editingChangedForTextField:", forControlEvents: .EditingChanged)
            cell.textField.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            cell.textField.textColor = context.style.redditUITextColor
            cell.textField.placeholder = "title"
            cell.textField.text = value.value
            cell.separatorHeight = 1.0 / context.style.scale
            cell.separatorView.backgroundColor = context.style.translucentDarkColor
        }
        presenter.select = { (context, value, cell, indexPath) -> () in
            cell.textField.becomeFirstResponder()
        }
        return presenter
    }
    
    private func subredditPresenter() -> TableViewCellPresenter<SubmitTextField, TextFieldCell, SubmitViewController> {
        let presenter = TableViewCellPresenter<SubmitTextField, TextFieldCell, SubmitViewController>(context: self, reuseIdentifier: SubmitFieldID.Subreddit.rawValue)
        presenter.present = { (context, value, cell, indexPath) -> () in
            cell.textField.delegate = self
            cell.textField.tag = indexPath.row + 1
            cell.textField.addTarget(self, action: "editingChangedForTextField:", forControlEvents: .EditingChanged)
            cell.textField.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            cell.textField.textColor = context.style.redditUITextColor
            cell.textField.placeholder = "subreddit"
            cell.textField.text = value.value
            cell.separatorHeight = 1.0 / context.style.scale
            cell.separatorView.backgroundColor = context.style.translucentDarkColor
        }
        presenter.select = { (context, value, cell, indexPath) -> () in
            cell.textField.becomeFirstResponder()
        }
        return presenter
    }
    
    private func urlPresenter() -> TableViewCellPresenter<SubmitURLField, URLFieldCell, SubmitViewController> {
        let presenter = TableViewCellPresenter<SubmitURLField, URLFieldCell, SubmitViewController>(context: self, reuseIdentifier: SubmitFieldID.URL.rawValue)
        presenter.present = { (context, value, cell, indexPath) -> () in
            cell.textField.delegate = self
            cell.textField.tag = indexPath.row + 1
            cell.textField.addTarget(self, action: "editingChangedForTextField:", forControlEvents: .EditingChanged)
            cell.textField.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            cell.textField.textColor = context.style.redditUITextColor
            cell.textField.placeholder = "URL"
            cell.textField.text = value.stringValue
            cell.separatorHeight = 1.0 / context.style.scale
            cell.separatorView.backgroundColor = context.style.translucentDarkColor
        }
        presenter.select = { (context, value, cell, indexPath) -> () in
            cell.textField.becomeFirstResponder()
        }
        return presenter
    }
    
    private func textPresenter() -> TableViewCellPresenter<SubmitLongTextField, LongTextFieldCell, SubmitViewController> {
        let presenter = TableViewCellPresenter<SubmitLongTextField, LongTextFieldCell, SubmitViewController>(context: self, reuseIdentifier: SubmitFieldID.Text.rawValue)
        presenter.present = { (context, value, cell, indexPath) -> () in
            cell.disclosureLabel.font = UIFont(name:"ionicons", size: 30.0)
            cell.disclosureLabel.textColor = context.style.redditUITextColor
            cell.disclosureLabel.text = "\u{f3d1}"
            cell.textField.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            cell.textField.textColor = context.style.redditUITextColor
            cell.textField.placeholder = "text"
            cell.textField.text = value.value
            cell.textField.userInteractionEnabled = false
            cell.separatorHeight = 1.0 / context.style.scale
            cell.separatorView.backgroundColor = context.style.translucentDarkColor
        }
        presenter.select = { (context, value, cell, indexPath) -> () in
            context.delegate?.sumbitViewController(context, willEditLongTextField: value)
        }
        return presenter
    }
    
    private func sendRepliesPresenter() -> TableViewCellPresenter<SubmitBoolField, BoolFieldCell, SubmitViewController> {
        let presenter = TableViewCellPresenter<SubmitBoolField, BoolFieldCell, SubmitViewController>(context: self, reuseIdentifier: SubmitFieldID.SendReplies.rawValue)
        presenter.present = { (context, value, cell, indexPath) -> () in
            cell.switchControl.addTarget(context, action: "sendRepliesValueChangedForSwitchControl:", forControlEvents: .ValueChanged)
            cell.switchControl.on = value.value ?? false
            cell.titleLabel.text = "Send replies to my inbox"
            cell.titleLabel.textColor = context.style.redditUITextColor
            cell.titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
            cell.switchControl.onTintColor = context.style.redditUITextColor
            cell.separatorHeight = 1.0 / context.style.scale
            cell.separatorView.backgroundColor = context.style.translucentDarkColor
        }
        presenter.select = { (context, value, cell, indexPath) -> () in
            cell.switchControl.setOn(!cell.switchControl.on, animated: true)
            context.sendRepliesValueChangedForSwitchControl(cell.switchControl)
        }
        return presenter
    }
}
