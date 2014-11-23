//
//  AuthenticationController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/23/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

protocol AuthenticationController : Controller {
    var cancel: (() -> ())! { get set}
    var done: ((NSURLCredential) -> ())! { get set }
}
