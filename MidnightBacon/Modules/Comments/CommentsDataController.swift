//
//  CommentsDataController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 3/19/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation
import FranticApparatus

protocol CommentsDataControllerDelegate : class {
    func commentsDataControllerDidLoadComments(commentsDataController: CommentsDataController)
}

class CommentsDataController {
    var gateway: Gateway!
    var sessionService: SessionService!
    weak var delegate: CommentsDataControllerDelegate!
    
    var link: Link

    var commentsPromise: Promise<(Link, Listing)>!
    var rootComments: [CommentDataController]?
    var moreComments: MoreCommentsDataController?
    
    init(link: Link) {
        self.link = link
    }

    func loadComments() {
        assert(commentsPromise == nil, "Already loading comments")
        let commentsRequest = CommentsRequest(article: link)
        commentsPromise = loadComments(commentsRequest).then(self, { (controller, result) -> Result<(Link, Listing)> in
            let loadedLink = result.0
            if loadedLink.id != controller.link.id {
                return Result(UnexpectedJSONError())
            }
            
            controller.link = loadedLink
//            controller.rootComments =
            return Result(result)
        })
    }
    
    func loadComments(commentsRequest: CommentsRequest) -> Promise<(Link, Listing)> {
        return sessionService.openSession(required: false).then(self, { (controller, session) -> Result<(Link, Listing)> in
            return Result(controller.gateway.performRequest(commentsRequest, session: session))
        }).recover(self, { (controller, error) -> Result<(Link, Listing)> in
            println(error)
            switch error {
            case let redditError as RedditError:
                if redditError.requiresReauthentication {
                    controller.sessionService.closeSession()
                    return Result(controller.loadComments(commentsRequest))
                } else {
                    return Result(error)
                }
            default:
                return Result(error)
            }
        })
    }
}
