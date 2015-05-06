//
//  Link.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

public class Link : Thing {
    public let title: String
    public let url: NSURL
    public let thumbnail: Thumbnail?
    public let created: NSDate
    public let author: String
    public let domain: String
    public let subreddit: String
    public let commentCount: Int
    public let permalink: String
    public let over18: Bool
    public let distinguished: String
    public let stickied: Bool
    public let visited: Bool
    public let saved: Bool
    public let isSelf: Bool
    public var likes: VoteDirection
    
    public init(
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

public enum Thumbnail : Equatable, Hashable, Printable {
    case URL(NSURL)
    case BuiltIn(BuiltInType)
    
    public var stringValue: String {
        switch self {
        case .URL(let url):
            return url.absoluteString!
        case .BuiltIn(let type):
            return type.rawValue
        }
    }
    
    public var hashValue: Int {
        return stringValue.hashValue
    }
    
    public var description: String {
        return stringValue
    }
}

public func ==(lhs: Thumbnail, rhs: Thumbnail) -> Bool {
    return lhs.stringValue == rhs.stringValue
}

public enum BuiltInType : String {
    case NSFW = "nsfw"
    case SelfPost = "self"
    case Default = "default"
}
