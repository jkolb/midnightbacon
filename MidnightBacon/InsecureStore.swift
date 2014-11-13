//
//  InsecureStore.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/12/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

protocol InsecureStore {
    var lastAuthenticatedUsername: String? { get set }
}
