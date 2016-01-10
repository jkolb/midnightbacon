//
//  Menu.swift
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

import Foundation

public enum MenuItemType {
    case Action
    case Selection
    case Navigation
}

public class MenuItem<E> {
    let type: MenuItemType
    let title: String
    let event: E
    var selected: Bool
    
    init(type: MenuItemType, title: String, event: E, selected: Bool) {
        self.type = type
        self.title = title
        self.event = event
        self.selected = selected
    }
}

public class MenuGroup<E> {
    let title: String
    private var items = [MenuItem<E>]()

    init(title: String) {
        self.title = title
    }
    
    subscript(index: Int) -> MenuItem<E> {
        return items[index]
    }
    
    var count: Int {
        return items.count
    }
    
    func addItem(type: MenuItemType, title: String, event: E, selected: Bool = false) {
        items.append(MenuItem<E>(type: type, title: title, event: event, selected: selected))
    }
}

public protocol MenuDataSource {
    func numberOfGroups() -> Int
    func numberOfItemsInGroup(group: Int) -> Int
    func titleForGroup(group: Int) -> String
    func typeForItemAtIndexPath(indexPath: NSIndexPath) -> MenuItemType
    func titleForItemAtIndexPath(indexPath: NSIndexPath) -> String
    func isSelectedItemAtIndexPath(indexPath: NSIndexPath) -> Bool
    func selectItemAtIndexPath(indexPath: NSIndexPath)
    func sendEventForItemAtIndexPath(indexPath: NSIndexPath)
}

public class Menu<E> : MenuDataSource {
    public var eventHandler: ((E) -> ())?
    private var groups = [MenuGroup<E>]()
    
    public func addGroup(title: String) {
        groups.append(MenuGroup<E>(title: title))
    }
    
    public func addActionItem(title: String, event: E) {
        groups.last!.addItem(.Action, title: title, event: event)
    }
    
    public func addSelectionItem(title: String, event: E, selected: Bool) {
        groups.last!.addItem(.Selection, title: title, event: event, selected: selected)
    }
    
    public func addNavigationItem(title: String, event: E) {
        groups.last!.addItem(.Navigation, title: title, event: event)
    }

    public subscript(index: Int) -> MenuGroup<E> {
        return groups[index]
    }
    
    public subscript(indexPath: NSIndexPath) -> MenuItem<E> {
        return groups[indexPath.section][indexPath.row]
    }
    
    public var count: Int {
        return groups.count
    }

    
    // MARK: - MenuDataSource
    
    public func numberOfGroups() -> Int {
        return count
    }
    
    public func numberOfItemsInGroup(group: Int) -> Int {
        return self[group].count
    }
    
    public func titleForGroup(group: Int) -> String {
        return self[group].title
    }

    public func typeForItemAtIndexPath(indexPath: NSIndexPath) -> MenuItemType {
        return self[indexPath].type
    }
    
    public func titleForItemAtIndexPath(indexPath: NSIndexPath) -> String {
        return self[indexPath].title
    }
    
    public func isSelectedItemAtIndexPath(indexPath: NSIndexPath) -> Bool {
        return self[indexPath].selected
    }

    public func selectItemAtIndexPath(indexPath: NSIndexPath) {
        let group = groups[indexPath.section]
        for item in group.items {
            item.selected = false
        }
        self[indexPath].selected = true
    }

    public func sendEventForItemAtIndexPath(indexPath: NSIndexPath) {
        eventHandler?(self[indexPath].event)
    }
}
