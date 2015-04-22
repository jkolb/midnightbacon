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
    let thumbnail: Thumbnail?
    let created: NSDate
    let author: String
    let domain: String
    let subreddit: String
    let commentCount: Int
    let permalink: String
    let over18: Bool
    let distinguished: String
    let stickied: Bool
    let visited: Bool
    let saved: Bool
    let isSelf: Bool
    var likes: VoteDirection
    
    init(
        id: String,
        name: String,
        title: String,
        url: NSURL,
        thumbnail: Thumbnail?,
        created: NSDate,
        author: String,
        domain: String,
        subreddit: String,
        commentCount: Int,
        permalink: String,
        over18: Bool,
        distinguished: String,
        stickied: Bool,
        visited: Bool,
        saved: Bool,
        isSelf: Bool,
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
        self.distinguished = distinguished
        self.stickied = stickied
        self.visited = visited
        self.saved = saved
        self.isSelf = isSelf
        self.likes = likes
        super.init(kind: .Link, id: id, name: name)
    }
}

enum Thumbnail : Equatable, Hashable, Printable {
    case URL(NSURL)
    case BuiltIn(BuiltInType)
    
    var stringValue: String {
        switch self {
        case .URL(let url):
            return url.absoluteString!
        case .BuiltIn(let type):
            return type.rawValue
        }
    }
    
    var hashValue: Int {
        return stringValue.hashValue
    }
    
    var description: String {
        return stringValue
    }
}

func ==(lhs: Thumbnail, rhs: Thumbnail) -> Bool {
    return lhs.stringValue == rhs.stringValue
}

enum BuiltInType : String {
    case NSFW = "nsfw"
    case SelfPost = "self"
    case Default = "default"
}
