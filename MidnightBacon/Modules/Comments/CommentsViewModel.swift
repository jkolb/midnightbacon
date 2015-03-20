//
//  CommentsViewModel.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 3/19/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation
import FranticApparatus

protocol CommentsViewModelDelegate : class {
    func commentsViewModelDidLoadComments(commentsViewModel: CommentsViewModel)
}

class CommentsViewModel {
    let linkTitle: String
    let linkURL: NSURL
    var commentsPromise: Promise<Listing>!
    
    init(linkTitle: String, linkURL: NSURL) {
        self.linkTitle = linkTitle
        self.linkURL = linkURL
    }
    
    func loadComments() {
        assert(commentsPromise == nil, "Already loading comments")
        commentsPromise = Promise<Listing> { (fulfill, reject, isCancelled) in
        };
    }
}
