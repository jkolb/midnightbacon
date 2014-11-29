//
//  MidnightBacon.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/29/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

protocol MidnightBacon {
    func start()
}

func MidnightBaconUserInterfaceIdiomInstance() -> MidnightBacon {
    switch UIDevice.currentDevice().userInterfaceIdiom {
    case .Pad:
        return MidnightBacon_iPad()
    case .Phone:
        return MidnightBacon_iPhone()
    default:
        fatalError("Unknown device idiom")
    }
}
