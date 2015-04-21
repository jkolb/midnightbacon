//
//  Menu.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

enum MenuItemType {
    case Action
    case Selection
    case Navigation
}

class MenuItem<E> {
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

class MenuGroup<E> {
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

protocol MenuDataSource {
    func numberOfGroups() -> Int
    func numberOfItemsInGroup(group: Int) -> Int
    func titleForGroup(group: Int) -> String
    func typeForItemAtIndexPath(indexPath: NSIndexPath) -> MenuItemType
    func titleForItemAtIndexPath(indexPath: NSIndexPath) -> String
    func isSelectedItemAtIndexPath(indexPath: NSIndexPath) -> Bool
    func selectItemAtIndexPath(indexPath: NSIndexPath)
    func sendEventForItemAtIndexPath(indexPath: NSIndexPath)
}

class Menu<E> : MenuDataSource {
    var eventHandler: ((E) -> ())?
    private var groups = [MenuGroup<E>]()
    
    func addGroup(title: String) {
        groups.append(MenuGroup<E>(title: title))
    }
    
    func addActionItem(title: String, event: E) {
        groups.last!.addItem(.Action, title: title, event: event)
    }
    
    func addSelectionItem(title: String, event: E, selected: Bool) {
        groups.last!.addItem(.Selection, title: title, event: event, selected: selected)
    }
    
    func addNavigationItem(title: String, event: E) {
        groups.last!.addItem(.Navigation, title: title, event: event)
    }

    subscript(index: Int) -> MenuGroup<E> {
        return groups[index]
    }
    
    subscript(indexPath: NSIndexPath) -> MenuItem<E> {
        return groups[indexPath.section][indexPath.row]
    }
    
    var count: Int {
        return groups.count
    }

    
    // MARK: - MenuDataSource
    
    func numberOfGroups() -> Int {
        return count
    }
    
    func numberOfItemsInGroup(group: Int) -> Int {
        return self[group].count
    }
    
    func titleForGroup(group: Int) -> String {
        return self[group].title
    }

    func typeForItemAtIndexPath(indexPath: NSIndexPath) -> MenuItemType {
        return self[indexPath].type
    }
    
    func titleForItemAtIndexPath(indexPath: NSIndexPath) -> String {
        return self[indexPath].title
    }
    
    func isSelectedItemAtIndexPath(indexPath: NSIndexPath) -> Bool {
        return self[indexPath].selected
    }

    func selectItemAtIndexPath(indexPath: NSIndexPath) {
        let group = groups[indexPath.section]
        for item in group.items {
            item.selected = false
        }
        self[indexPath].selected = true
    }

    func sendEventForItemAtIndexPath(indexPath: NSIndexPath) {
        if let eventHandler = self.eventHandler {
            eventHandler(self[indexPath].event)
        }
    }
}
