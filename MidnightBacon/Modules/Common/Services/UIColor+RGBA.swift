//
//  UIColor+RGBA.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

extension UIColor {
    public convenience init(_ red: UInt8, _ green: UInt8, _ blue: UInt8) {
        let r = CGFloat(red) / 255.0
        let g = CGFloat(green) / 255.0
        let b = CGFloat(blue) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    public convenience init(_ rgb: UInt32) {
        let r = UInt8((rgb & 0x00FF0000) >> 16)
        let g = UInt8((rgb & 0x0000FF00) >> 08)
        let b = UInt8((rgb & 0x000000FF) >> 00)
        self.init(r, g, b)
    }
}
