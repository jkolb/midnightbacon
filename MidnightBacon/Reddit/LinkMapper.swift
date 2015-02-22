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
        let url = json["url"].url
        
        if url == nil {
            return Outcome(Error(message: "Skipped link due to invalid URL: " + (json["url"].string as! String)))
        }
        
        return Outcome(
            Link(
                id: json["id"].string as! String,
                name: json["name"].string as! String,
                title: json["title"].unescapedString,
                url: url!,
                thumbnail: json["thumbnail"].thumbnail,
                created: json["created_utc"].date,
                author: json["author"].string as! String,
                domain: json["domain"].string as! String,
                subreddit: json["subreddit"].string as! String,
                commentCount: json["num_comments"].integer,
                permalink: json["permalink"].string as! String,
                over18: json["over_18"].boolean,
                likes: json["likes"].voteDirection
            )
        )
    }
}
