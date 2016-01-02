//
//  Link.swift
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

public enum Thumbnail : Equatable, Hashable, CustomStringConvertible {
    case URL(NSURL)
    case BuiltIn(BuiltInType)
    
    public var stringValue: String {
        switch self {
        case .URL(let url):
            return url.absoluteString
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
