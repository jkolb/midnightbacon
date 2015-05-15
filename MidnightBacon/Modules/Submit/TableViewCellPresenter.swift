//
//  TableViewCellPresenter.swift
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

protocol TableCellPresenter {
    func registerCellClassForTableView(tableView: UITableView)
    func cellForRowInTableView(tableView: UITableView, atIndexPath indexPath: NSIndexPath, withValue value: Any) -> UITableViewCell
    func heightForRowInTableView(tableView: UITableView, atIndexPath indexPath: NSIndexPath, withValue value: Any) -> CGFloat
    func selectRowInTableView(tableView: UITableView, atIndexPath indexPath: NSIndexPath, withValue value: Any)
    func deselectRowInTableView(tableView: UITableView, atIndexPath indexPath: NSIndexPath, withValue value: Any)
}

class TableViewCellPresenter<ValueType, CellType: UITableViewCell, ContextType: AnyObject> : TableCellPresenter {
    let reuseIdentifier: String
    private weak var context: ContextType?
    var present: ((ContextType, ValueType, CellType, NSIndexPath) -> ())?
    var select: ((ContextType, ValueType, CellType, NSIndexPath) -> ())?
    var deselect: ((ContextType, ValueType, CellType?, NSIndexPath) -> ())?
    private var sizingCell: CellType!
    
    init(context: ContextType, reuseIdentifier: String) {
        self.context = context
        self.reuseIdentifier = reuseIdentifier
    }
    
    func registerCellClassForTableView(tableView: UITableView) {
        tableView.registerClass(CellType.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    func cellForRowInTableView(tableView: UITableView, atIndexPath indexPath: NSIndexPath, withValue value: Any) -> UITableViewCell {
        let typedCell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CellType
        let typedValue = value as! ValueType
        if let strongContext = context {
            present?(strongContext, typedValue, typedCell, indexPath)
        }
        return typedCell
    }
    
    func heightForRowInTableView(tableView: UITableView, atIndexPath indexPath: NSIndexPath, withValue value: Any) -> CGFloat {
        if sizingCell == nil {
            sizingCell = CellType()
        }

        let typedValue = value as! ValueType
        if let strongContext = context {
            present?(strongContext, typedValue, sizingCell, indexPath)
        }
        let fitSize = CGSize(width: tableView.bounds.width, height: 10_000.00)
        let sizeThatFits = sizingCell.sizeThatFits(fitSize)
        return sizeThatFits.height
    }
    
    func selectRowInTableView(tableView: UITableView, atIndexPath indexPath: NSIndexPath, withValue value: Any) {
        let typedCell = tableView.cellForRowAtIndexPath(indexPath) as! CellType
        let typedValue = value as! ValueType
        if let strongContext = context {
            select?(strongContext, typedValue, typedCell, indexPath)
        }
    }
    
    func deselectRowInTableView(tableView: UITableView, atIndexPath indexPath: NSIndexPath, withValue value: Any) {
        let typedCell = tableView.cellForRowAtIndexPath(indexPath) as? CellType
        let typedValue = value as! ValueType
        if let strongContext = context {
            deselect?(strongContext, typedValue, typedCell, indexPath)
        }
    }
}
