//
//  JSON+Reddit.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation
import ModestProposal

extension JSON {
    var date: NSDate {
        return NSDate(timeIntervalSince1970: number.doubleValue)
    }
    
    var dateOrNil: NSDate? {
        if let number = numberOrNil {
            return date
        } else {
            return nil
        }
    }
    
    var url: NSURL? {
        return string.length == 0 ? nil : NSURL(string: string)
    }
    
    var voteDirection: VoteDirection {
        if let nonNilNumber = numberOrNil {
            if nonNilNumber.boolValue {
                return .Upvote
            } else {
                return .Downvote
            }
        } else {
            return .None
        }
    }
    
    var unescapedString: String {
        let string: String = self.string
        return string.unescapeEntities()
    }
    
    var integer: Int {
        return number.integerValue
    }
    
    var boolean: Bool {
        return number.boolValue
    }
}
