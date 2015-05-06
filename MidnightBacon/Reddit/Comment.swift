//
//  Comment.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 3/19/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation

public class Comment : Thing {
    public let parentID: String
    public let author: String
    public let body: String
    public let bodyHTML: String
    public let createdUTC: NSDate
    public let replies: Listing?
    public var depth = 0
    
    public init(id: String, name: String, parentID: String, author: String, body: String, bodyHTML: String, createdUTC: NSDate, replies: Listing?) {
        self.parentID = parentID
        self.author = author
        self.body = body
        self.bodyHTML = bodyHTML
        self.createdUTC = createdUTC
        self.replies = replies
        super.init(kind: .Comment, id: id, name: name)
    }
}
