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
    
    var linksPromise: Promise<Updates>?
    var links =  Reddit.Links.none()
    var thumbnails = [Int:UIImage]()
    var thumbnailPromises = [Int:Promise<UIImage>]()
    let thumbnailService: ThumbnailService
    var linksLoaded: (([NSIndexPath]) -> ())?
    var linksPreloaded: (() -> ())?
    var linksError: ((error: Error) -> ())?
    
    let synchronizationQueue: DispatchQueue = GCDQueue.serial("LinksController")
    var uniqueLinks = Dictionary<String, Reddit.Link>() // Only access when synchronized

    init(reddit: Reddit, path: String) {
        self.reddit = reddit
        self.path = path
        self.thumbnailService = ThumbnailService(source: reddit)
    }
    
    func fetchLinks() {
        linksPromise = fetchLinks(path, query: [:], preload: false)
    }
    
    func prefetch(indexPath: NSIndexPath) {
        if linksPromise != nil {
            return
        }
        
        if links.count == 0 {
            return
        }
        
        if indexPath.row < (links.count / 2) {
            return
        }
        
        fetchNext()
    }
    
    func fetchNext(preload: Bool = true) {
        if let lastLink = links.last {
            linksPromise = fetchLinks(path, query: ["after": lastLink.name], preload: preload)
        }
    }
    
    struct Updates {
        let links: Reddit.Links
        let indexPaths: [NSIndexPath]
    }
    
    func fetchLinks(path: String, query: [String:String], preload: Bool) -> Promise<Updates> {
        let deduplicate = self.deduplicateLinks
        let genenerateIndexPaths = self.generateUpdatedIndexPaths
        let oldLinks = self.links
        return reddit.fetchReddit(path, query: query).when({ (links) -> Result<Reddit.Links> in
            return .Deferred(deduplicate(links))
        }).when({ (links) -> Result<Updates> in
            return .Deferred(genenerateIndexPaths(oldLinks: oldLinks, newLinks: links))
        }).when({ [weak self] (updates) -> () in
            if let strongSelf = self {
                strongSelf.links.add(updates.links)
                
                if preload {
                    strongSelf.linksPreloaded?()
                } else {
                    strongSelf.linksLoaded?(updates.indexPaths)
                }
            }
        }).catch({ [weak self] (error) -> () in
            if let strongSelf = self {
                strongSelf.linksError?(error: error)
            }
        }).finally({ [weak self] in
            if let strongSelf = self {
                strongSelf.linksPromise = nil
            }
        })
    }
    
    func generateUpdatedIndexPaths(# oldLinks: Reddit.Links, newLinks: Reddit.Links) -> Promise<Updates> {
        let promise = Promise<Updates>()
        synchronizeWrite(self) { [weak promise] (synchronizedSelf) in
            if let strongPromise = promise {
                if newLinks.count > 0 {
                    let startRow = oldLinks.count
                    let endRow = startRow + newLinks.count - 1
                    var indexPaths = [NSIndexPath]()
                    
                    for row in startRow...endRow {
                        indexPaths.append(NSIndexPath(forRow: row, inSection: 0))
                    }
                    
                    var updatedLinks = Array<Reddit.Link>()
                    updatedLinks.extend(oldLinks.links)
                    updatedLinks.extend(newLinks.links)
                    
                    let updated = Reddit.Links(links: updatedLinks, after: newLinks.after, before: newLinks.before, modhash: newLinks.modhash)
                    
                    strongPromise.fulfill(Updates(links: updated, indexPaths: indexPaths))
                } else {
                    strongPromise.fulfill(Updates(links: oldLinks, indexPaths: []))
                }
            }
        }
        return promise
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
    
    func fetchThumbnail(thumbnail: String, key: NSIndexPath) -> UIImage? {
        return thumbnailService.load(thumbnail, key: key)
    }
    
    subscript(indexPath: NSIndexPath) -> Reddit.Link {
        return links[indexPath.row]
    }
    
    var count: Int {
        return links.count
    }
    
    var thumbnailLoaded: ((image: UIImage, key: NSIndexPath) -> ())? {
        get {
            return thumbnailService.success
        }
        set {
            thumbnailService.success = newValue
        }
    }
    
    var thumbnailError: ((error: Error, key: NSIndexPath) -> ())? {
        get {
            return thumbnailService.failure
        }
        set {
            thumbnailService.failure = newValue
        }
    }
}
