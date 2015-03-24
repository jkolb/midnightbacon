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
    func commentsDataControllerDidBeginLoad(commentsDataController: CommentsDataController)
    func commentsDataControllerDidEndLoad(commentsDataController: CommentsDataController)
    func commentsDataControllerDidLoadComments(commentsDataController: CommentsDataController)
    func commentsDataController(commentsDataController: CommentsDataController, didFailWithReason reason: Error)
}

class CommentsDataController {
    var gateway: Gateway!
    var sessionService: SessionService!
    weak var delegate: CommentsDataControllerDelegate!
    
    var link: Link
    var listing: Listing!
    
    var commentsPromise: Promise<(Link, Listing)>!
    
    init(link: Link) {
        self.link = link
    }

    var isLoaded: Bool {
        return listing != nil
    }

    func refreshComments() {
        listing = nil
        loadComments()
    }
    
    func loadComments() {
        assert(!isLoaded, "Already loading comments")
        let commentsRequest = CommentsRequest(article: link)
        commentsPromise = loadComments(commentsRequest).then(self, { (controller, result) -> Result<(Link, Listing)> in
            let loadedLink = result.0
            if loadedLink.id != controller.link.id {
                return Result(UnexpectedJSONError())
            }
            
            controller.link = loadedLink
            controller.listing = result.1
            
            controller.didLoadComments()
            
            return Result(result)
        }).finally(self, { controller in
            controller.commentsPromise = nil
        })
    }
    
    func didLoadComments() {
        if let strongDelegate = delegate {
            strongDelegate.commentsDataControllerDidLoadComments(self)
        }
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
