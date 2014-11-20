//
//  NSURLCredential+SecureData.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

extension NSURLCredential {
    var secureData: NSData? {
        if let p = password {
            return p.UTF8Data
        } else {
            return nil
        }
    }
}
