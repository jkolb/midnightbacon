//
//  AccountMapper.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/11/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import ModestProposal
import FranticApparatus

class AccountMapper : ThingMapper {
    func map(json: JSON) -> Outcome<Thing, Error> {
        return Outcome(
            Account(
                id: json["id"].string as! String,
                name: json["name"].string as! String,
                modhash: json["modhash"].string as! String,
                linkKarma: json["link_karma"].integer,
                commentKarma: json["comment_karma"].integer,
                created: json["created"].date,
                createdUTC: json["created_utc"].date,
                hasMail: json["has_mail"].boolean,
                hasModMail: json["has_mod_mail"].boolean,
                hasVerifiedEmail: json["has_verified_email"].boolean,
                hideFromRobots: json["hide_from_robots"].boolean,
                isFriend: json["is_friend"].boolean,
                isMod: json["is_mod"].boolean,
                over18: json["over_18"].boolean,
                isGold: json["is_gold"].boolean,
                goldCreddits: json["gold_creddits"].integer,
                goldExpiration: json["gold_expiration"].dateOrNil
            )
        )
    }
}
