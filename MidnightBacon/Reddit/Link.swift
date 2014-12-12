//
//  Link.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

class Link : Thing {
    let title: String
    let url: NSURL
    let thumbnail: String
    let created: NSDate
    let author: String
    let domain: String
    let subreddit: String
    let commentCount: Int
    let permalink: String
    let over18: Bool
    var likes: VoteDirection
    
    init(
        id: String,
        name: String,
        title: String,
        url: NSURL,
        thumbnail: String,
        created: NSDate,
        author: String,
        domain: String,
        subreddit: String,
        commentCount: Int,
        permalink: String,
        over18: Bool,
        likes: VoteDirection
        )
    {
        self.title = title
        self.url = url
        self.thumbnail = thumbnail
        self.created = created
        self.author = author
        self.domain = domain
        self.subreddit = subreddit
        self.commentCount = commentCount
        self.permalink = permalink
        self.over18 = over18
        self.likes = likes
        super.init(kind: .Link, id: id, name: name)
    }
    
    var hasThumbnail: Bool {
        return countElements(thumbnail) > 0
    }
}
