//
//  TableViewCellPresenter.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 5/8/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
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
