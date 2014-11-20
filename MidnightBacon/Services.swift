//
//  Services.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

protocol Services {
    var style: Style { get }
    var gateway: Gateway { get }
    var secureStore: SecureStore { get }
    var insecureStore: InsecureStore { get }
}
