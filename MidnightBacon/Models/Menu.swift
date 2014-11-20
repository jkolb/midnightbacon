//
//  Menu.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

class Menu {
    struct Item {
        let title: String
        let action: () -> ()
    }

    struct Group {
        let title: String
        let items: [Item]
        
        subscript(index: Int) -> Item {
            return items[index]
        }
        
        var count: Int {
            return items.count
        }
    }
    
    var groups = [Group]()
    
    func addGroup(# title: String, items: [Item]) {
        groups.append(Group(title: title, items: items))
    }

    subscript(index: Int) -> Group {
        return groups[index]
    }
    
    subscript(indexPath: NSIndexPath) -> Item {
        return groups[indexPath.section][indexPath.row]
    }
    
    var count: Int {
        return groups.count
    }
}
