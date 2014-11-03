//
//  LinksController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

class LinksController : Synchronizable {
    let reddit: Reddit
    let path: String
    let synchronizationQueue: DispatchQueue = GCDQueue.serial("LinksController")
    var uniqueLinks = Dictionary<String, Reddit.Link>() // Only access when synchronized

    init(reddit: Reddit, path: String) {
        self.reddit = reddit
        self.path = path
    }
    
    func fetchLinks()  -> Promise<Reddit.Links> {
        return fetchLinks(path)
    }
    
    func fetchLinks(path: String, query: [String:String] = [:]) -> Promise<Reddit.Links> {
        let deduplicate = self.deduplicateLinks
        return reddit.fetchReddit(path, query: query).when { (links) -> Result<Reddit.Links> in
            return .Deferred(deduplicate(links))
        }
    }
    
    func deduplicateLinks(links: Reddit.Links) -> Promise<Reddit.Links> {
        let promise = Promise<Reddit.Links>()
        synchronizeWrite(self) { [weak promise] (synchronizedSelf) in
            if let strongPromise = promise {
                var filteredLinks = Array<Reddit.Link>()
                
                for link in links.links {
                    if synchronizedSelf.uniqueLinks[link.id] == nil  {
                        filteredLinks.append(link)
                        synchronizedSelf.uniqueLinks[link.id] = link
                    }
                }
                
                strongPromise.fulfill(
                    Reddit.Links(
                        links: filteredLinks,
                        after: links.after,
                        before: links.before,
                        modhash: links.modhash
                    )
                )
            }
        }
        return promise
    }
}
