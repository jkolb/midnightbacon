//
//  ImageSource.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation
import UIKit
import FranticApparatus

public protocol ImageSource {
    func requestImage(url: NSURL) -> Promise<UIImage>
}
