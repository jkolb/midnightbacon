//
//  NSData+HTTP.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/19/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

extension NSData {
    class func formURLEncode(parameters: [String:String]?, encoding: UInt = NSUTF8StringEncoding) -> NSData? {
        let components = NSURLComponents()
        components.parameters = parameters
        return components.query?.dataUsingEncoding(encoding, allowLossyConversion: false)
    }
}
