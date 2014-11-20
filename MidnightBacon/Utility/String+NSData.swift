//
//  String+NSData.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

extension String {
    var UTF8Data: NSData? {
        if countElements(self) == 0 {
            return nil
        } else {
            return dataUsingEncoding(NSUTF8StringEncoding)
        }
    }
}
