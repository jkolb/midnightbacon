//
//  NSURLSessionConfiguration+NoCookies.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/23/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

extension NSURLSessionConfiguration {
    func noCookies() -> NSURLSessionConfiguration {
        HTTPCookieAcceptPolicy = .Never
        HTTPShouldSetCookies = false
        HTTPCookieStorage = nil
        return self
    }
}
