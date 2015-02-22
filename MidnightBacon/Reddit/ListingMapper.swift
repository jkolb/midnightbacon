//
//  ListingMapper.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/11/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import ModestProposal
import FranticApparatus

class ListingMapper {
    var thingMapper: ThingMapper!
    
    init() { }
    
    func map(json: JSON) -> Outcome<Listing, Error> {
        let kindRawValue = json["kind"].string as! String
        let kindOrNil = Kind(rawValue: kindRawValue)
        
        if let kind = kindOrNil {
            let data = json["data"]
            
            if !data.isObject {
                return Outcome(UnexpectedJSONError(message: "Missing thing data"))
            }
            
            let children = data["children"]
            
            if !children.isArray {
                return Outcome(UnexpectedJSONError(message: "Listing missing children"))
            }
            
            var things = [Thing]()
            
            for index in 0..<children.count {
                let child = children[index]
                let mapResult = thingMapper.map(child)
                
                switch mapResult {
                case .Success(let thing):
                    things.append(thing.unwrap)
                case .Failure(let error):
                    println(error.unwrap)
                }
            }

            return Outcome(
                Listing(
                    children: things,
                    after: data["after"].string as! String,
                    before: data["before"].string as! String,
                    modhash: data["modhash"].string as! String
                )
            )
        } else {
            return Outcome(UnexpectedJSONError(message: "Unknown kind: \(kindRawValue)"))
        }
    }
}
