//
//  MoreMapper.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 3/19/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import ModestProposal
import FranticApparatus

class MoreMapper : ThingMapper {
    func map(json: JSON) -> Outcome<Thing, Error> {
        return Outcome(
            More(
                id: json["id"].asString ?? "",
                name: json["name"].asString ?? "",
                parentID: json["parentID"].asString ?? "",
                count: json["count"].asInteger ?? 0,
                children: json["children"].asStringArray ?? []
            )
        )
    }
}
