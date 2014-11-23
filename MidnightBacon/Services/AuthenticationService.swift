//
//  AuthenticationService.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/23/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

protocol AuthenticationService {
    func authenticate() -> Promise<NSURLCredential>
}
