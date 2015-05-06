//
//  Debug.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/19/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation

public func asJSON(object: AnyObject?) -> String {
    if let nonNilObject: AnyObject = object {
        if let JSONData = NSJSONSerialization.dataWithJSONObject(nonNilObject, options: .PrettyPrinted, error: nil) {
            if let JSONString = NSString(data: JSONData, encoding: NSUTF8StringEncoding) {
                return JSONString as String
            } else {
                return "Unable to turn into JSON string"
            }
        } else {
            return "Unable to format as JSON"
        }
    } else {
        return "null"
    }
}
