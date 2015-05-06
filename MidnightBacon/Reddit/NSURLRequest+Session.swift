//
//  NSURLRequest+Session.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/30/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation
import Common

extension NSMutableURLRequest {
    func applyAccessToken(accessToken: AuthorizationToken?) {
        if let accessToken = accessToken {
            if accessToken.isValid {
                // Authorization: bearer J1qK1c18UUGJFAzz9xnH56584l4
                self[.Authorization] = accessToken.authorization
            }
        }
    }
}
