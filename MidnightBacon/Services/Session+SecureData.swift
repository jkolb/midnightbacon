//
//  Session+SecureData.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

extension Session {
    var secureData: NSData? {
        return SessionMapper().toData(self)
    }
    
    static func secureData(data: NSData) -> Session {
        return SessionMapper().fromData(data)
    }
}
