//
//  LinksDataController.swift
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

import FranticApparatus
import ModestProposal
import Common
import Reddit

protocol LinksDataControllerDelegate : class {
    func linksDataControllerDidBeginLoad(linksDataController: LinksDataController)
    func linksDataControllerDidEndLoad(linksDataController: LinksDataController)
    func linksDataControllerDidLoadLinks(linksDataController: LinksDataController)
    func linksDataController(linksDataController: LinksDataController, didFailWithReason reason: ErrorType)
}

class LinksDataController {
    var redditRequest: RedditRequest!
    var oauthService: OAuthService!
    var gateway: Gateway!
    var thumbnailService: ThumbnailService!
    weak var delegate: LinksDataControllerDelegate?
    
    // MARK: - Model
    var path: String!
    var pages = [Listing]()

    var loadedLinks = [String:Link]()
    var linksPromise: Promise<Listing>?

    init() { }
    
    func refresh() {
        pages.removeAll(keepCapacity: true)
        loadedLinks.removeAll(keepCapacity: true)
        linksPromise = nil
        fetchNext()
    }
    
    func fetchNext() {
        var request: APIRequestOf<Listing>!
        
        if let lastPage = pages.last {
            if let lastLink = lastPage.children.last {
                request = redditRequest.subredditLinks(path, after: lastLink.name)
            } else {
                request = redditRequest.subredditLinks(path)
            }
        } else {
            request = redditRequest.subredditLinks(path)
        }
        
        didBeginLoad()
        
        fetchLinks(request) { [weak self] (links, error) in
            if let strongSelf = self {
                strongSelf.didEndLoad()
                
                if let nonNilError = error {
                    strongSelf.didFailWithReason(nonNilError)
                } else if let nonNilLinks = links {
                    strongSelf.addPage(nonNilLinks)
                }
            }
        }
    }
    
    var numberOfPages: Int {
        return pages.count
    }
    
    func numberOfLinksForPage(page: Int) -> Int {
        return pages[page].count
    }
    
    func addPage(links: Listing) {
        if links.count == 0 {
            return
        }
        
        let firstPage = pages.count == 0
        pages.append(links)
        
        if firstPage {
            didLoadLinks()
        }
    }
    
    func didBeginLoad() {
        if let strongDelegate = delegate {
            strongDelegate.linksDataControllerDidBeginLoad(self)
        }
    }
    
    func didEndLoad() {
        if let strongDelegate = delegate {
            strongDelegate.linksDataControllerDidEndLoad(self)
        }
    }
    
    func didFailWithReason(reason: ErrorType) {
        if let strongDelegate = delegate {
            strongDelegate.linksDataController(self, didFailWithReason: reason)
        }
    }
    
    func didLoadLinks() {
        if let strongDelegate = delegate {
            strongDelegate.linksDataControllerDidLoadLinks(self)
        }
    }
    
    func linkForIndexPath(indexPath: NSIndexPath) -> Link {
        let thing = pages[indexPath.section][indexPath.row]
        
        switch thing {
        case let link as Link:
            return link
        default:
            fatalError("Not a link: \(thing.kind)")
        }
    }

//    func voteOn(voteRequest: VoteRequest) -> Promise<Bool> {
//        return sessionService.openSession(required: true).then(self, { (interactor, session) -> Result<Bool> in
//            return Result(interactor.gateway.performRequest(voteRequest, session: session))
//        }).recover(self, { (interactor, error) -> Result<Bool> in
//            println(error)
//            switch error {
//            case let redditError as RedditError:
//                if redditError.requiresReauthentication {
//                    interactor.sessionService.closeSession()
//                    return Result(interactor.voteOn(voteRequest))
//                } else {
//                    return Result(error)
//                }
//            default:
//                return Result(error)
//            }
//        })
//    }
    
    func fetchLinks(subredditRequest: APIRequestOf<Listing>, completion: (Listing?, ErrorType?) -> ()) {
        if linksPromise == nil {
            linksPromise = oauthFetchLinks(subredditRequest).thenWithContext(self, { (controller, links) -> Promise<Listing> in
                return controller.filterLinks(links, allowDups: false, allowOver18: false)
            }).then({ (links) -> Void in
                completion(links, nil)
            }).handle({ (error) -> Void in
                completion(nil, error)
            }).finallyWithContext(self, { (interactor) -> Void in
                interactor.linksPromise = nil
            })
        }
    }
    
    func filterLinks(listing: Listing, allowDups: Bool, allowOver18: Bool) -> Promise<Listing> {
        return Promise<Listing> { (fulfill, reject, isCancelled) in
            let allow: (Link) -> Bool = { [weak self] (link) in
                if let strongSelf = self {
                    let allowedDuplicate = strongSelf.loadedLinks[link.id] == nil || allowDups
                    let allowedOver18 = !link.over18 || allowOver18
                    strongSelf.loadedLinks[link.id] = link
                    return allowedDuplicate && allowedOver18
                } else {
                    return false
                }
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                var allowedThings = [Thing]()
                
                for thing in listing.children {
                    switch thing {
                    case let link as Link:
                        if allow(link) {
                            allowedThings.append(link)
                        }
                    default:
                        allowedThings.append(thing)
                    }
                }
                
                let allowed = Listing(children: allowedThings, after: listing.after, before: listing.before, modhash: listing.modhash)
                
                fulfill(allowed)
            }
        }
    }
    
    func oauthFetchLinks(subredditRequest: APIRequestOf<Listing>, forceRefresh: Bool = false) -> Promise<Listing> {
        return oauthService.aquireAccessToken(forceRefresh: forceRefresh).thenWithContext(self, { (interactor, accessToken) -> Promise<Listing> in
            return interactor.gateway.performRequest(subredditRequest, accessToken: accessToken)
        }).recoverWithContext(self, { (interactor, error) -> Promise<Listing> in
            switch error {
            case RedditAPIError.Unauthorized:
                if forceRefresh {
                    throw error
                } else {
                    return interactor.oauthFetchLinks(subredditRequest, forceRefresh: true)
                }
            default:
                throw error
            }
        })
    }
    
    func loadThumbnail(thumbnail: Thumbnail, key: NSIndexPath, completion: (NSIndexPath, UIImage!, ErrorType!) -> ()) -> UIImage? {
        return thumbnailService.load(thumbnail, key: key, completion: completion)
    }
}
