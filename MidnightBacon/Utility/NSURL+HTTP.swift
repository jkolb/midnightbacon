//
//  NSURL+Components.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/17/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

extension NSURL {
    func buildURL(path pathOrNil: String?, parameters: [String:String]? = nil) -> NSURL? {
        if let components = NSURLComponents(URL: self, resolvingAgainstBaseURL: true) {
            components.path = String.pathWithComponents([components.path ?? "", path ?? ""])
            components.parameters = parameters
            return components.URL
        } else {
            return nil
        }
    }
}
