//
//  LinksController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

class LinksController {
    let reddit: Reddit
    let path: String
    var pages = Array<Listing<Link>>()
    var linksPromise: Promise<Listing<Link>>?
    var thumbnails = [Int:UIImage]()
    var thumbnailPromises = [Int:Promise<UIImage>]()
    let thumbnailService: ThumbnailService
    var linksLoaded: (() -> ())?
    var linksError: ((error: Error) -> ())?
    var loadedLinks = [String:Link]()
    
    init(reddit: Reddit, path: String) {
        self.reddit = reddit
        self.path = path
        self.thumbnailService = ThumbnailService(source: reddit)
    }
    
    func fetchLinks() {
        linksPromise = fetchLinks(path, query: [:])
    }
    
    func fetchNext() {
        if pages.count == 0 {
            return
        }
        
        if let fetching = linksPromise {
            return
        }
        
        if let lastPage = pages.last {
            if let lastLink = lastPage.children.last {
                linksPromise = fetchLinks(path, query: ["after": lastLink.name])
            }
        }
    }
    
    func fetchLinks(path: String, query: [String:String]) -> Promise<Listing<Link>> {
        let filter = filterLinks
        return reddit.fetchReddit(path, query: query).when({ (links) -> Result<Listing<Link>> in
            return .Deferred(filter(links, allowDups: false, allowOver18: false))
        }).when({ [weak self] (links) in
            if let strongSelf = self {
                if links.count > 0 {
                    strongSelf.pages.append(links)
                    strongSelf.linksLoaded?()
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
    
    func filterLinks(links: Listing<Link>, allowDups: Bool, allowOver18: Bool) -> Promise<Listing<Link>> {
        let promise = Promise<Listing<Link>>()
        var loaded = loadedLinks
        let allow: (Link) -> Bool = { (link) in
            let allowedDuplicate = loaded[link.id] == nil || allowDups
            let allowedOver18 = !link.over18 || allowOver18
            loaded[link.id] = link
            return allowedDuplicate && allowedOver18
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [weak promise] in
            if let strongPromise = promise {
                var allowedLinks = [Link]()
                
                for link in links.children {
                    if allow(link) {
                        allowedLinks.append(link)
                    }
                }
                
                let allowed = Listing<Link>(children: allowedLinks, after: links.after, before: links.before, modhash: links.modhash)
                
                strongPromise.fulfill(allowed)
            }
        }
        return promise
    }
    
    func fetchThumbnail(thumbnail: String, key: NSIndexPath) -> UIImage? {
        return thumbnailService.load(thumbnail, key: key)
    }
    
    subscript(page: Int) -> Listing<Link> {
        return pages[page]
    }
    
    subscript(indexPath: NSIndexPath) -> Link {
        return pages[indexPath.section][indexPath.row]
    }
    
    var numberOfPages: Int {
        return pages.count
    }
    
    func numberOfLinks(page: Int) -> Int {
        return pages[page].count
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
