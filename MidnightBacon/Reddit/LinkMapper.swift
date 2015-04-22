//
//  LinkMapper.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/11/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import ModestProposal
import FranticApparatus

class LinkMapper : ThingMapper {
    init() { }
    
    func map(json: JSON) -> Outcome<Thing, Error> {
        if let url = json["url"].asURL {
            return Outcome(
                Link(
                    id: json["id"].asString ?? "",
                    name: json["name"].asString ?? "",
                    title: json["title"].asUnescapedString ?? "",
                    url: url,
                    thumbnail: json["thumbnail"].thumbnail,
                    created: json["created_utc"].asSecondsSince1970 ?? NSDate(),
                    author: json["author"].asString ?? "",
                    domain: json["domain"].asString ?? "",
                    subreddit: json["subreddit"].asString ?? "",
                    commentCount: json["num_comments"].asInteger ?? 0,
                    permalink: json["permalink"].asString ?? "",
                    over18: json["over_18"].asBoolean ?? false,
                    distinguished: json["over_18"].asString ?? "",
                    stickied: json["stickied"].asBoolean ?? false,
                    visited: json["visited"].asBoolean ?? false,
                    saved: json["saved"].asBoolean ?? false,
                    isSelf: json["is_self"].asBoolean ?? false,
                    likes: json["likes"].asVoteDirection
                )
            )
        } else {
            return Outcome(Error(message: "Skipped link due to invalid URL: " + (json["url"].asString ?? "")))
        }
    }
}
