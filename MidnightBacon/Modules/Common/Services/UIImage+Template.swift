//
//  UIImage+Template.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/30/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import DrapierLayout

extension UIImage {
    public func tinted(tintColor: UIColor) -> UIImage {
        let template = self.imageWithRenderingMode(.AlwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(template.size, false, 0.0)
        tintColor.setFill()
        template.drawInRect(template.size.rect())
        let tinted = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tinted
    }
}
