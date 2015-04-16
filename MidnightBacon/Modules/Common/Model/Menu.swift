//
//  Menu.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

struct Item<A> {
    let title: String
    let action: A
}

class Group<A> {
    let title: String
    private var items = [Item<A>]()

    init(title: String) {
        self.title = title
    }
    
    subscript(index: Int) -> Item<A> {
        return items[index]
    }
    
    var count: Int {
        return items.count
    }
    
    func addItem(title: String, action: A) {
        items.append(Item<A>(title: title, action: action))
    }
}

class Menu<A> {
    var actionHandler: ((A) -> ())?
    private var groups = [Group<A>]()
    
    func addGroup(title: String) {
        groups.append(Group<A>(title: title))
    }

    func addItem(title: String, action: A) {
        groups.last?.addItem(title, action: action)
    }
    
    subscript(index: Int) -> Group<A> {
        return groups[index]
    }
    
    subscript(indexPath: NSIndexPath) -> Item<A> {
        return groups[indexPath.section][indexPath.row]
    }
    
    var count: Int {
        return groups.count
    }

    func triggerActionAtIndexPath(indexPath: NSIndexPath) {
        if let actionHandler = self.actionHandler {
            actionHandler(self[indexPath].action)
        }
    }
}
