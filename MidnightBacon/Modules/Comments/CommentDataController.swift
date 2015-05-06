//
//  CommentDataController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 3/22/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Reddit

class CommentDataController {
    let comment: Comment
    let parent: CommentDataController?
    
    init(comment: Comment, parent: CommentDataController?) {
        self.comment = comment
        self.parent = parent
    }
}
