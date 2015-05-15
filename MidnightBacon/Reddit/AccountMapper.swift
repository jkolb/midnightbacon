//
//  AccountMapper.swift
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
