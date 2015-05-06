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
    var redditRequest: RedditRequest!
    var oauthService: OAuthService!
    var gateway: Gateway!
    weak var delegate: CommentsDataControllerDelegate!
    
    var link: Link
    var comments: [Thing] = []
    private var _isLoaded = false
    var commentsPromise: Promise<(Listing, [Thing])>!
    
    init(link: Link) {
        self.link = link
    }

    func commentAtIndexPath(indexPath: NSIndexPath) -> Comment? {
        let thing = comments[indexPath.row]
        
        switch thing {
        case let comment as Comment:
            return comment
        default:
            return nil
        }
    }
    
    func moreAtIndexPath(indexPath: NSIndexPath) -> More? {
        let thing = comments[indexPath.row]
        
        switch thing {
        case let more as More:
            return more
        default:
            return nil
        }
    }
    
    var count: Int {
        return comments.count
    }
    
    var isLoaded: Bool {
        return _isLoaded
    }

    func refreshComments() {
        _isLoaded = false
        comments.removeAll(keepCapacity: true)
        loadComments()
    }
    
    func loadComments() {
        delegate.commentsDataControllerDidBeginLoad(self)
        
        assert(!isLoaded, "Already loading comments")
        let commentsRequest = redditRequest.linkComments(link)
        commentsPromise = oauthLoadComments(commentsRequest).then(self, { (controller, result) -> Result<(Listing, [Thing])> in
            let loadedLinkListing = result.0
            
            if  loadedLinkListing.children.count != 1 {
                return Result(UnexpectedJSONError())
            }
            
            let loadedLink = loadedLinkListing.children[0] as! Link
            
            if loadedLink.id != controller.link.id {
                return Result(UnexpectedJSONError())
            }
            
            controller.link = loadedLink
            controller.comments = result.1
            
            controller.didLoadComments()
            
            return Result(result)
        }).finally(self, { controller in
            controller.commentsPromise = nil
            controller.delegate?.commentsDataControllerDidEndLoad(controller)
        })
    }
    
    func didLoadComments() {
        if let strongDelegate = delegate {
            strongDelegate.commentsDataControllerDidLoadComments(self)
        }
    }
    
    func oauthLoadComments(commentsRequest: APIRequestOf<(Listing, [Thing])>, forceRefresh: Bool = false) -> Promise<(Listing, [Thing])> {
        return oauthService.aquireAccessToken(forceRefresh: forceRefresh).then(self, { (controller, accessToken) -> Result<(Listing, [Thing])> in
            return Result(controller.gateway.performRequest(commentsRequest, accessToken: accessToken))
        }).recover(self, { (controller, error) -> Result<(Listing, [Thing])> in
            switch error {
            case let unauthorizedError as UnauthorizedError:
                if forceRefresh {
                    return Result(error)
                } else {
                    return Result(controller.oauthLoadComments(commentsRequest, forceRefresh: true))
                }
            default:
                return Result(error)
            }
        })
    }
}
