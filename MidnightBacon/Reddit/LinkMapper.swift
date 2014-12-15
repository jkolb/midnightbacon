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
    
    func map(json: JSON) -> ParseResult<Thing> {
        let url = json["url"].url
        
        if url == nil {
            return .Failure(Error(message: "Skipped link due to invalid URL: " + json["url"].string))
        }
        
        return .Success(
            Link(
                id: json["id"].string,
                name: json["name"].string,
                title: json["title"].unescapedString,
                url: url!,
                thumbnail: json["thumbnail"].thumbnail,
                created: json["created_utc"].date,
                author: json["author"].string,
                domain: json["domain"].string,
                subreddit: json["subreddit"].string,
                commentCount: json["num_comments"].integer,
                permalink: json["permalink"].string,
                over18: json["over_18"].boolean,
                likes: json["likes"].voteDirection
            )
        )
    }
}
