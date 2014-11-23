//
//  ControllerPresenterService.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/23/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

protocol ControllerPresenterService {
    func presentController(controller: Controller, animated: Bool, completion: (() -> ())?)
    func dismissController(# animated: Bool, completion: (() -> ())?)
}
