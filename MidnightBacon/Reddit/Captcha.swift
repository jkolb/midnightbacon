//
//  Captcha.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/30/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

class Captcha {
    let iden: String
    let image: UIImage
    var text: String?
    
    init(iden: String, image: UIImage) {
        self.iden = iden
        self.image = image
    }
}
