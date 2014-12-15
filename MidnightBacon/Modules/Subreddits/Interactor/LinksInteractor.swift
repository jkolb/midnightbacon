//
//  LinksInteractor.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/22/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

class LinksInteractor {
    var gateway: Gateway!
    var sessionService: SessionService!
    var thumbnailService: ThumbnailService!
    
    var loadedLinks = [String:Link]()
    var linksPromise: Promise<Listing>?

    init() { }
    
    func voteOn(link: Link, direction: VoteDirection) -> Promise<Bool> {
        return sessionService.openSession(required: true).when(self, { (interactor, session) -> Result<Bool> in
            return .Deferred(interactor.gateway.vote(session: session, link: link, direction: direction))
        }).recover(self, { (interactor, error) -> Result<Bool> in
            println(error)
            switch error {
            case let redditError as RedditError:
                if redditError.requiresReauthentication {
                    interactor.sessionService.closeSession()
                    return .Deferred(interactor.voteOn(link, direction: direction))
                } else {
                    return .Failure(error)
                }
            default:
                return .Failure(error)
            }
        })
    }
    
    func fetchLinks(path: String, query: [String:String], completion: (Listing?, Error?) -> ()) {
        if linksPromise == nil {
            linksPromise = sessionFetchLinks(path, query: query).when(self, { (controller, links) -> Result<Listing> in
                return .Deferred(controller.filterLinks(links, allowDups: false, allowOver18: false))
            }).when({ (links) -> () in
                completion(links, nil)
            }).catch({ (error) -> () in
                completion(nil, error)
            }).finally(self, { (interactor) in
                interactor.linksPromise = nil
            })
        }
    }
    
    func filterLinks(listing: Listing, allowDups: Bool, allowOver18: Bool) -> Promise<Listing> {
        let promise = Promise<Listing>()
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [weak promise] in
            if let strongPromise = promise {
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
                
                strongPromise.fulfill(allowed)
            }
        }
        return promise
    }

    func sessionFetchLinks(path: String, query: [String:String]) -> Promise<Listing> {
        return sessionService.openSession(required: false).when(self, { (interactor, session) -> Result<Listing> in
            return .Deferred(interactor.gateway.fetchReddit(session: session, path: path, query: query))
        }).recover(self, { (interactor, error) -> Result<Listing> in
            println(error)
            switch error {
            case let redditError as RedditError:
                if redditError.requiresReauthentication {
                    interactor.sessionService.closeSession()
                    return .Deferred(interactor.sessionFetchLinks(path, query: query))
                } else {
                    return .Failure(error)
                }
            default:
                return .Failure(error)
            }
        })
    }
    
    func loadThumbnail(thumbnail: Thumbnail, key: NSIndexPath, completion: (NSIndexPath, Outcome<UIImage, Error>) -> ()) -> UIImage? {
        return thumbnailService.load(thumbnail, key: key, completion: completion)
    }
}
