//
//  AccountsController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/6/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

protocol AccountsActionController {
    func addAccount()
}

class AccountsController : NSObject, UINavigationControllerDelegate, AccountsActionController {
    var accountsFactory: AccountsFactory!
    var navigationController: UINavigationController!
    
    func addAccount() {
        
    }
}
