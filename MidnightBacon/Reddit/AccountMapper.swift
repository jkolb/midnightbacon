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

import Jasoom

class AccountMapper : ThingMapper {
    func map(json: JSON) throws -> Thing {
        return Account(
            id: json["id"].textValue ?? "",
            name: json["name"].textValue ?? "",
            modhash: json["modhash"].textValue ?? "",
            linkKarma: json["link_karma"].intValue ?? 0,
            commentKarma: json["comment_karma"].intValue ?? 0,
            created: json["created"].dateValue ?? NSDate(),
            createdUTC: json["created_utc"].dateValue ?? NSDate(),
            hasMail: json["has_mail"].boolValue ?? false,
            hasModMail: json["has_mod_mail"].boolValue ?? false,
            hasVerifiedEmail: json["has_verified_email"].boolValue ?? false,
            hideFromRobots: json["hide_from_robots"].boolValue ?? false,
            isFriend: json["is_friend"].boolValue ?? false,
            isMod: json["is_mod"].boolValue ?? false,
            over18: json["over_18"].boolValue ?? false,
            isGold: json["is_gold"].boolValue ?? false,
            goldCreddits: json["gold_creddits"].intValue ?? 0,
            goldExpiration: json["gold_expiration"].dateValue
        )
    }
}
