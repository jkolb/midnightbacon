//
//  SessionMapper.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/12/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation
import ModestProposal

class SessionMapper {
    func fromAPI(json: JSON) -> Session {
        let data = json[KeyPath("json.data")]
        return fromJSON(data)
    }
    
    func toJSON(session: Session) -> JSON {
        let json = JSON.object()
        json["modhash"] = session.modhash.json
        json["cookie"] = session.cookie.json
        json["need_https"] = session.needHTTPS.number.json
        return json
    }

    func fromJSON(json: JSON) -> Session {
        return Session(
            modhash: json["modhash"].string as! String,
            cookie: json["cookie"].string as! String,
            needHTTPS: json["need_https"].number.boolValue
        )
    }

    func fromData(data: NSData) -> Session {
        var error: NSError?
        
        if let json = JSON.parse(data, options: NSJSONReadingOptions(0), error: &error) {
            return fromJSON(json)
        } else {
            return Session(modhash: "", cookie: "", needHTTPS: false)
        }
    }
    
    func toData(session: Session) -> NSData {
        return toJSON(session).format()
    }
}

extension Bool {
    var number: NSNumber {
        return NSNumber(bool: self)
    }
}
