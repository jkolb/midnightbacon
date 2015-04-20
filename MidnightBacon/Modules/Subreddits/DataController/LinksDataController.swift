//
//  LinksDataController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/22/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus
import ModestProposal

protocol LinksDataControllerDelegate : class {
    func linksDataControllerDidBeginLoad(linksDataController: LinksDataController)
    func linksDataControllerDidEndLoad(linksDataController: LinksDataController)
    func linksDataControllerDidLoadLinks(linksDataController: LinksDataController)
    func linksDataController(linksDataController: LinksDataController, didFailWithReason reason: Error)
}

class LinksDataController {
    var gateway: Gateway!
    var sessionService: SessionService!
    var oauthService: OAuthService!
    var oauthGateway: OAuthGateway!
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
        var request: SubredditRequest!
        
        if let lastPage = pages.last {
            if let lastLink = lastPage.children.last {
                request = SubredditRequest(path: path, after: lastLink.name)
            } else {
                request = SubredditRequest(path: path)
            }
        } else {
            request = SubredditRequest(path: path)
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
    
    func didFailWithReason(reason: Error) {
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

    func voteOn(voteRequest: VoteRequest) -> Promise<Bool> {
        return sessionService.openSession(required: true).then(self, { (interactor, session) -> Result<Bool> in
            return Result(interactor.gateway.performRequest(voteRequest, session: session))
        }).recover(self, { (interactor, error) -> Result<Bool> in
            println(error)
            switch error {
            case let redditError as RedditError:
                if redditError.requiresReauthentication {
                    interactor.sessionService.closeSession()
                    return Result(interactor.voteOn(voteRequest))
                } else {
                    return Result(error)
                }
            default:
                return Result(error)
            }
        })
    }
    
    func fetchLinks(subredditRequest: SubredditRequest, completion: (Listing?, Error?) -> ()) {
        if linksPromise == nil {
            linksPromise = oauthFetchLinks(subredditRequest).then(self, { (controller, links) -> Result<Listing> in
                return Result(controller.filterLinks(links, allowDups: false, allowOver18: false))
            }).then({ (links) -> () in
                completion(links, nil)
            }).catch({ (error) -> () in
                completion(nil, error)
            }).finally(self, { (interactor) in
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
    
    func oauthFetchLinks(subredditRequest: SubredditRequest) -> Promise<Listing> {
        return oauthService.aquireAccessToken().then(self, { (interactor, accessToken) -> Result<Listing> in
            return Result(interactor.oauthGateway.performRequest(subredditRequest, accessToken: accessToken))
        })
    }

    func sessionFetchLinks(subredditRequest: SubredditRequest) -> Promise<Listing> {
        return sessionService.openSession(required: false).then(self, { (interactor, session) -> Result<Listing> in
            return Result(interactor.gateway.performRequest(subredditRequest, session: session))
        }).recover(self, { (interactor, error) -> Result<Listing> in
            println(error)
            switch error {
            case let redditError as RedditError:
                if redditError.requiresReauthentication {
                    interactor.sessionService.closeSession()
                    return Result(interactor.sessionFetchLinks(subredditRequest))
                } else {
                    return Result(error)
                }
            default:
                return Result(error)
            }
        })
    }
    
    func loadThumbnail(thumbnail: Thumbnail, key: NSIndexPath, completion: (NSIndexPath, Outcome<UIImage, Error>) -> ()) -> UIImage? {
        return thumbnailService.load(thumbnail, key: key, completion: completion)
    }
}
