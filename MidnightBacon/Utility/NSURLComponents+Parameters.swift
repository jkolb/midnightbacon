//
//  NSURLComponents+Parameters.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/17/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

extension NSURLComponents {
    var parameters: [String:String]? {
        get {
            if let items = queryItems as? [NSURLQueryItem] {
                var parameters = [String:String](minimumCapacity: items.count)
                for item in items {
                    parameters[item.name] = item.value
                }
                return parameters
            } else {
                return nil
            }
        }
        set {
            if let parameters = newValue {
                var items = [NSURLQueryItem]()
                items.reserveCapacity(parameters.count)
                for (name, value) in parameters {
                    items.append(NSURLQueryItem(name: name, value: value))
                }
                queryItems = items
            } else {
                queryItems = nil
            }
        }
    }
}
