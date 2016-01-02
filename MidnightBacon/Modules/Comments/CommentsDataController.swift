//
//  CommentsDataController.swift
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
import FranticApparatus
import Common
import Reddit

protocol CommentsDataControllerDelegate : class {
    func commentsDataControllerDidBeginLoad(commentsDataController: CommentsDataController)
    func commentsDataControllerDidEndLoad(commentsDataController: CommentsDataController)
    func commentsDataControllerDidLoadComments(commentsDataController: CommentsDataController)
    func commentsDataController(commentsDataController: CommentsDataController, didFailWithReason reason: ErrorType)
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
        commentsPromise = oauthLoadComments(commentsRequest).thenWithContext(self, { (controller, result) -> (Listing, [Thing]) in
            let loadedLinkListing = result.0
            
            if  loadedLinkListing.children.count != 1 {
                throw ThingError.UnexpectedJSON
            }
            
            let loadedLink = loadedLinkListing.children[0] as! Link
            
            if loadedLink.id != controller.link.id {
                throw ThingError.UnexpectedJSON
            }
            
            controller.link = loadedLink
            controller.comments = result.1
            
            controller.didLoadComments()
            
            return result
        }).finallyWithContext(self, { controller in
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
        return oauthService.aquireAccessToken(forceRefresh: forceRefresh).thenWithContext(self, { (controller, accessToken) -> Promise<(Listing, [Thing])> in
            return controller.gateway.performRequest(commentsRequest, accessToken: accessToken)
        }).recoverWithContext(self, { (controller, error) -> Promise<(Listing, [Thing])> in
            switch error {
            case RedditAPIError.Unauthorized:
                if forceRefresh {
                    throw error
                } else {
                    return controller.oauthLoadComments(commentsRequest, forceRefresh: true)
                }
            default:
                throw error
            }
        })
    }
}
