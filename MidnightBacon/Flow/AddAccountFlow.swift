//
//  AddAccountFlow.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/25/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class AddAccountFlow : Flow {
    var cancel: (() -> ())!
    var done: (() -> ())!
    
    init() {
    }
    
    lazy var addAccountInteractor: AddAccountInteractor = {
        let interactor = AddAccountInteractor()
        interactor.gateway = UIApplication.services.gateway
        interactor.secureStore = UIApplication.services.secureStore
        return interactor
    }()
    
    lazy var addAccountController: AddAccountController = { [unowned self] in
        let controller = AddAccountController()
        controller.interactor = self.addAccountInteractor
        controller.done = self.done
        controller.cancel = self.cancel
        return controller
    }()
    
    var startController: Controller {
        return addAccountController
    }
}
