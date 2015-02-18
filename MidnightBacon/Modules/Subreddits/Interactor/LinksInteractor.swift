//
//  LinksInteractor.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/22/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus
import ModestProposal

class LinksInteractor {
    var gateway: Gateway!
    var sessionService: SessionService!
    var thumbnailService: ThumbnailService!
    
    var loadedLinks = [String:Link]()
    var linksPromise: Promise<Listing>?

    init() { }
    
    func voteOn(voteRequest: VoteRequest) -> Promise<Bool> {
        return sessionService.openSession(required: true).when(self, { (interactor, session) -> Result<Bool> in
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
            linksPromise = sessionFetchLinks(subredditRequest).when(self, { (controller, links) -> Result<Listing> in
                return Result(controller.filterLinks(links, allowDups: false, allowOver18: false))
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

    func sessionFetchLinks(subredditRequest: SubredditRequest) -> Promise<Listing> {
        return sessionService.openSession(required: false).when(self, { (interactor, session) -> Result<Listing> in
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
