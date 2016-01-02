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

import Jasoom

class ListingMapper {
    var thingMapper: ThingMapper!
    
    init() { }
    
    func map(json: JSON) throws -> Listing {
        if let kind = json["kind"].kindValue {
            precondition(kind == .Listing)
            
            let data = json["data"]
            
            if !data.isObject {
                throw ThingError.MissingThingData
            }
            
            let children = data["children"]
            
            if !children.isArray {
                throw ThingError.ListingMissingChildren
            }
            
            var things = [Thing]()
            
            for index in 0..<children.count {
                let child = children[index]
                
                do {
                    let thing = try thingMapper.map(child)
                    things.append(thing)
                }
                catch {
                    // Do not add to listing
                    print(error)
                }
            }

            return Listing(
                children: things,
                after: data["after"].textValue ?? "",
                before: data["before"].textValue ?? "",
                modhash: data["modhash"].textValue ?? ""
            )

        } else {
            throw ThingError.UnknownKind(json["kind"].textValue ?? "")
        }
    }
}
