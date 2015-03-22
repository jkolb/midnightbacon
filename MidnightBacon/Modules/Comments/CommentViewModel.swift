//
//  CommentViewModel.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 3/22/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation

class CommentViewModel {
    let parent: CommentViewModel?
    let author: String
    let body: String
    let bodyHTML: String
    let createdUTC: NSDate
    let replies: [CommentViewModel]
    let moreComments: MoreCommentsViewModel?
    
    init(parent: CommentViewModel?, author: String, body: String, bodyHTML: String, createdUTC: NSDate, replies: [CommentViewModel], moreComments: MoreCommentsViewModel?) {
        self.parent = parent
        self.author = author
        self.body = body
        self.bodyHTML = bodyHTML
        self.createdUTC = createdUTC
        self.replies = replies
        self.moreComments = moreComments
    }
}
