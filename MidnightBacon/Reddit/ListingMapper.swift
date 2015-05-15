//
//  ListingMapper.swift
//  MidnightBacon
//
// Copyright (c) 2015 Justin Kolb - http://franticapparatus.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import ModestProposal
import FranticApparatus

class ListingMapper {
    var thingMapper: ThingMapper!
    
    init() { }
    
    func map(json: JSON) -> Outcome<Listing, Error> {
        let kindRawValue = json["kind"].asString ?? ""
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
                    after: data["after"].asString ?? "",
                    before: data["before"].asString ?? "",
                    modhash: data["modhash"].asString ?? ""
                )
            )
        } else {
            return Outcome(UnexpectedJSONError(message: "Unknown kind: \(kindRawValue)"))
        }
    }
}
