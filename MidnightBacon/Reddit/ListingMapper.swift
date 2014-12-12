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
    
    func map(json: JSON) -> ParseResult<Listing> {
        let kindRawValue = json["kind"].string
        let kindOrNil = Kind(rawValue: kindRawValue)
        
        if let kind = kindOrNil {
            let data = json["data"]
            
            if !data.isObject {
                return .Failure(Error(message: "Missing thing data"))
            }
            
            let children = data["children"]
            
            if !children.isArray {
                return .Failure(UnexpectedJSONError(message: "Listing missing children"))
            }
            
            var things = [Thing]()
            
            for index in 0..<children.count {
                let child = children[index]
                let mapResult = thingMapper.map(child)
                
                switch mapResult {
                case .Success(let thing):
                    things.append(thing())
                case .Failure(let error):
                    println(error)
                }
            }
            
            return .Success(
                Listing(
                    children: things,
                    after: data["after"].string,
                    before: data["before"].string,
                    modhash: data["modhash"].string
                )
            )
        } else {
            return .Failure(Error(message: "Unknown kind: \(kindRawValue)"))
        }
    }
}
