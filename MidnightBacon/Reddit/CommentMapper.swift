//
//  CommentMapper.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 3/19/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import ModestProposal
import FranticApparatus

/*
{
    "data": {
        "approved_by": null,
        "archived": false,
        "author": "StacySwanson",
        "author_flair_css_class": null,
        "author_flair_text": null,
        "banned_by": null,
        "body": "no",
        "body_html": "&lt;div class=\"md\"&gt;&lt;p&gt;no&lt;/p&gt;\n&lt;/div&gt;",
        "controversiality": 0,
        "created": 1426841872.0,
        "created_utc": 1426813072.0,
        "distinguished": null,
        "downs": 0,
        "edited": false,
        "gilded": 0,
        "id": "cpkivdp",
        "likes": null,
        "link_id": "t3_2zmdjk",
        "mod_reports": [],
        "name": "t1_cpkivdp",
        "num_reports": null,
        "parent_id": "t1_cpki27u",
        "replies": "",
        "report_reasons": null,
        "saved": false,
        "score": 1,
        "score_hidden": false,
        "subreddit": "funny",
        "subreddit_id": "t5_2qh33",
        "ups": 1,
        "user_reports": []
    },
    "kind": "t1"
}
 */
class CommentMapper : ThingMapper {
    var listingMapper: ListingMapper!
    
    func map(json: JSON) -> Outcome<Thing, Error> {
        var replies: Listing?
        
        switch listingMapper.map(json["replies"]) {
        case .Success(let result):
            replies = result.unwrap
        case .Failure(let reason):
            replies = Listing(children: [], after: "", before: "", modhash: "")
        }
        
        return Outcome(
            Comment(
                id: json["id"].asString ?? "",
                name: json["name"].asString ?? "",
                parentID: json["parentID"].asString ?? "",
                author: json["author"].asString ?? "",
                body: json["body"].asUnescapedString ?? "",
                bodyHTML: json["body_html"].asUnescapedString ?? "",
                createdUTC: json["created_utc"].asSecondsSince1970 ?? NSDate(),
                replies: replies
            )
        )
    }
}
