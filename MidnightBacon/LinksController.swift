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
    
    var linksPromise: Promise<Reddit.Links>!
    var links =  Reddit.Links.none()
    var thumbnails = [Int:UIImage]()
    var thumbnailPromises = [Int:Promise<UIImage>]()
    let thumbnailService: ThumbnailService<NSIndexPath>
    var linksLoaded: (() -> ())?
    var linksError: ((error: Error) -> ())?
    
    let synchronizationQueue: DispatchQueue = GCDQueue.serial("LinksController")
    var uniqueLinks = Dictionary<String, Reddit.Link>() // Only access when synchronized

    init(reddit: Reddit, path: String) {
        self.reddit = reddit
        self.path = path
        self.thumbnailService = ThumbnailService<NSIndexPath>(source: reddit)
    }
    
    func fetchLinks() {
        linksPromise = fetchLinks(path).when({ [weak self] (links) -> () in
            if let strongSelf = self {
                strongSelf.links = links
                strongSelf.linksLoaded?()
            }
        }).catch({ [weak self] (error) -> () in
            self?.linksError?(error: error)
            return
        }).finally({ [weak self] in
            self?.linksPromise = nil
            return
        })
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
