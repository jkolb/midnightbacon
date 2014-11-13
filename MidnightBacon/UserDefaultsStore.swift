//
//  UserDefaultsStore.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/12/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

class UserDefaultsStore : InsecureStore {
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var lastAuthenticatedUsername: String? {
        get {
            return defaults.stringForKey("MB_LAST_AUTH_USER")
        }
        set {
            defaults.setObject(newValue, forKey: "MB_LAST_AUTH_USER")
            defaults.synchronize()
        }
    }
}
