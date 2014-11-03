//
//  Menu.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

class Menu {
    struct Item {
        let title: String
        let action: () -> ()
    }

    struct Group {
        let title: String
        let items: [Item]
    }
    
    var groups = [Group]()
    
    func addGroup(title: String, items: [Item]) -> Group {
        let group = Group(title: title, items: items)
        groups.append(group)
        return group
    }
}
