//
//  Comment.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 3/19/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation

class Comment : Thing {
    let parentID: String
    let author: String
    let body: String
    let bodyHTML: String
    let createdUTC: NSDate
    let replies: Listing?
    
    init(id: String, name: String, parentID: String, author: String, body: String, bodyHTML: String, createdUTC: NSDate, replies: Listing?) {
        self.parentID = parentID
        self.author = author
        self.body = body
        self.bodyHTML = bodyHTML
        self.createdUTC = createdUTC
        self.replies = replies
        super.init(kind: .Comment, id: id, name: name)
    }
}
