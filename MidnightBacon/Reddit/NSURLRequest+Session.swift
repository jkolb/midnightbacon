//
//  NSURLRequest+Session.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/30/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

extension NSMutableURLRequest {
    func applySession(session: Session) {
        if countElements(session.cookie) > 0 {
            if let cookie = session.cookie.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
                self[.Cookie] = "reddit_session=\(cookie)"
            }
        }
        
        if countElements(session.modhash) > 0 {
            self["X-Modhash"] = session.modhash
        }
    }
}
