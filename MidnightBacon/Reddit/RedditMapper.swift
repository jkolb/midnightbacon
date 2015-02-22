//
//  RedditMapper.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/11/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import ModestProposal
import FranticApparatus

class RedditMapper : ThingMapper {
    var thingMappers: [Kind:ThingMapper]!
    
    init() { }
    
    func map(json: JSON) -> Outcome<Thing, Error> {
        let kindRawValue = json["kind"].string
        let kindOrNil = Kind(rawValue: kindRawValue as! String)
        
        if let kind = kindOrNil {
            let data = json["data"]
            
            if !data.isObject {
                return Outcome(Error(message: "Missing thing data"))
            }

            if let mapper = thingMappers[kind] {
                return mapper.map(data)
            } else {
                return Outcome(Error(message: "No mapper for kind: \(kindRawValue)"))
            }
        } else {
            return Outcome(Error(message: "Unknown kind: \(kindRawValue)"))
        }
    }
}
