//
//  ListView.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/11/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

@objc protocol ListViewDataSource {
    func numberOfItemsInListView(listView: ListView) -> Int
    func listView(listView: ListView, cellForItemAtIndex index: Int) -> ListViewCell
    optional func listView(listView: ListView, willDisplayCell cell: ListViewCell, forItemAtIndex index: Int)
    optional func listView(listView: ListView, didSelectCellAtIndex index: Int)
}

class ListView : UIScrollView {
    weak var dataSource: ListViewDataSource?
    private var isReloading = true
    private var _visibleCells = [Int:ListViewCell]()
    private var _frameCache = [CGRect]()
    private var _cellClass = [String:ListViewCell.Type]()
    private var _cellCache = [String:[ListViewCell]]()
    
    func reloadData() {
        resetInitialState()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func cellForIndex(index: Int) -> ListViewCell? {
        return _visibleCells[index]
    }
    
    func indexesOfVisibleItems() -> [Int] {
        return sorted(_visibleCells.keys)
    }
    
    func registerClass(cellClass: ListViewCell.Type, forCellReuseIdentifier identifier: String) {
        _cellClass[identifier] = cellClass
        _cellCache[identifier] = [ListViewCell]()
    }
    
    func dequeueReusableCellWithIdentifier(identifier: String) -> UIView {
        if let cachedCell = _cellCache[identifier]!.last {
            _cellCache[identifier]!.removeLast()
            cachedCell.prepareForReuse()
            return cachedCell
        } else if let cellClass = _cellClass[identifier] {
            return cellClass(frame: CGRect.zeroRect, reuseIdentifier: identifier)
        } else {
            fatalError("No cell class registered for identifier '\(identifier)'")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isReloading {
            loadInitialViews()
            isReloading = false
        } else {
            for index in _visibleCells.keys {
                let visibleCell = _visibleCells[index]!
                if !bounds.intersects(visibleCell.frame) {
                    _cellCache[visibleCell.reuseIdentifier]!.append(visibleCell)
                    visibleCell.removeFromSuperview()
                    visibleCell.listView = nil
                    visibleCell.cellIndex = -1
                    _visibleCells[index] = nil
                }
            }
            
            if let dataSource = self.dataSource {
                let numberOfItems = dataSource.numberOfItemsInListView(self)
                
                if numberOfItems > 0  {
                    var cellIndex = startFrameIndexForYOffset(bounds.minY)
                    var cellFrame = _frameCache[cellIndex]
                    
                    while bounds.intersects(cellFrame) {
                        if _visibleCells[cellIndex] == nil {
                            let cell = dataSource.listView(self, cellForItemAtIndex: cellIndex)
                            displayCell(cell, atIndex: cellIndex, usingFrame: cellFrame)
                        }
                        
                        ++cellIndex
                        
                        if cellIndex >= numberOfItems {
                            break;
                        }
                        cellFrame = _frameCache[cellIndex]
                    }
                }
            }
        }
    }
    
    private func startFrameIndexForYOffset(yOffset: CGFloat) -> Int {
        var minIndex = 0
        var maxIndex = _frameCache.count - 1
        
        while maxIndex >= minIndex {
            let midIndex = minIndex + ((maxIndex - minIndex) / 2)
            
            let midFrame = _frameCache[midIndex]
            
            if midFrame.minY <= yOffset && midFrame.maxY >= yOffset {
                return midIndex
            } else if midFrame.maxY < yOffset {
                minIndex = midIndex + 1
            } else {
                maxIndex = midIndex - 1
            }
        }
        
        return 0
    }
    
    private func resetInitialState() {
        isReloading = true
        
        for (_, cell) in _visibleCells {
            cell.removeFromSuperview()
        }
        
        for (_, var cache) in _cellCache {
            cache.removeAll(keepCapacity: true)
        }
        
        _frameCache.removeAll(keepCapacity: true)
        _visibleCells.removeAll(keepCapacity: true)
    }
    
    private func loadInitialViews() {
        if let dataSource = self.dataSource {
            let count = dataSource.numberOfItemsInListView(self)
            var cellFrame = CGRect.zeroRect
            cellFrame.size.width = bounds.width
            let fitSize = CGSizeMake(cellFrame.width, 10_000.0)
            
            for var index = 0; index < count; ++index {
                let cell = dataSource.listView(self, cellForItemAtIndex: index)
                let cellHeight = cell.sizeThatFits(fitSize).height
                cellFrame.size.height = cellHeight
                _frameCache.append(cellFrame)
                
                if bounds.intersects(cellFrame) {
                    displayCell(cell, atIndex: index, usingFrame: cellFrame)
                } else {
                    _cellCache[cell.reuseIdentifier]!.append(cell)
                }
                
                cellFrame.origin.y += cellHeight
            }
            
            contentSize = CGSize(width: cellFrame.width, height: cellFrame.minY)
        }
    }
    
    private func displayCell(cell: ListViewCell, atIndex index: Int, usingFrame frame: CGRect) {
        _visibleCells[index] = cell
        cell.cellIndex = index
        cell.frame = frame
        cell.setNeedsLayout()
        dataSource?.listView?(self, willDisplayCell: cell, forItemAtIndex: index)
        addSubview(cell)
        cell.listView = self
    }
    
    private func selectedCell(cell: ListViewCell) {
        dataSource?.listView?(self, didSelectCellAtIndex: cell.cellIndex)
    }
}

class ListViewCell : UIView {
    let reuseIdentifier: String
    private var cellIndex: Int = -1
    private var listView: ListView?
    
    required init(frame: CGRect, reuseIdentifier: String) {
        self.reuseIdentifier = reuseIdentifier
        super.init(frame: frame)
        opaque = true
    }
    
    required init(coder aDecoder: NSCoder) {
        reuseIdentifier = aDecoder.decodeObjectOfClass(NSString.self, forKey: "reuseIdentifier") as! String
        super.init(coder: aDecoder)
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 44.0)
    }
    
    func prepareForReuse() {
    }
    
    // Generally, all responders which do custom touch handling should override all four of these methods.
    // Your responder will receive either touchesEnded:withEvent: or touchesCancelled:withEvent: for each
    // touch it is handling (those touches it received in touchesBegan:withEvent:).
    // *** You must handle cancelled touches to ensure correct behavior in your application.  Failure to
    // do so is very likely to lead to incorrect behavior or crashes.
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        listView?.selectedCell(self)
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        
    }
}
