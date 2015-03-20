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
                id: json["id"].asString ?? "",
                name: json["name"].asString ?? "",
                modhash: json["modhash"].asString ?? "",
                linkKarma: json["link_karma"].asInteger ?? 0,
                commentKarma: json["comment_karma"].asInteger ?? 0,
                created: json["created"].asSecondsSince1970 ?? NSDate(),
                createdUTC: json["created_utc"].asSecondsSince1970 ?? NSDate(),
                hasMail: json["has_mail"].asBoolean ?? false,
                hasModMail: json["has_mod_mail"].asBoolean ?? false,
                hasVerifiedEmail: json["has_verified_email"].asBoolean ?? false,
                hideFromRobots: json["hide_from_robots"].asBoolean ?? false,
                isFriend: json["is_friend"].asBoolean ?? false,
                isMod: json["is_mod"].asBoolean ?? false,
                over18: json["over_18"].asBoolean ?? false,
                isGold: json["is_gold"].asBoolean ?? false,
                goldCreddits: json["gold_creddits"].asInteger ?? 0,
                goldExpiration: json["gold_expiration"].asSecondsSince1970
            )
        )
    }
}
