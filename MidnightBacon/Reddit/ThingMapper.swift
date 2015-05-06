//
//  ThingMapper.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/11/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import ModestProposal
import FranticApparatus

public class UnexpectedJSONError : Error { }

protocol ThingMapper {
    func map(json: JSON) -> Outcome<Thing, Error>
}
