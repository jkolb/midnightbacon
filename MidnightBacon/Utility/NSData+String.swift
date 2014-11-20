//
//  NSData+String.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

extension NSData {
    var UTF8String: String? {
        if length == 0 {
            return nil
        } else {
            return NSString(data: self, encoding: NSUTF8StringEncoding)
        }
    }
}
