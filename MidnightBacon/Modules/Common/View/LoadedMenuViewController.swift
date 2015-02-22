//
//  LoadedMenuViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

protocol MenuLoader {
    func loadMenu() -> Promise<Menu>
}

class LoadedMenuViewController : MenuViewController {
    var loader: MenuLoader!
    var promise: Promise<Menu>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menu = Menu()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if menu.count == 0 && promise == nil {
            reload()
        }
    }
    
    func reload() {
        promise = loader.loadMenu().then(self, { (context, menu) -> () in
            context.showMenu(menu)
        })
    }
    
    func showMenu(menu: Menu) {
        self.menu = menu
        tableView.reloadData()
    }
}
