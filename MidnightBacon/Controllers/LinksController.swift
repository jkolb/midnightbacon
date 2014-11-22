//
//  LinksController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

class LinksController : NSObject, Controller, UIActionSheetDelegate {
    let reddit: RedditController
    let path: String
    var linksPromise: Promise<Listing<Link>>?
    let thumbnailService: ThumbnailService
    var linksError: ((error: Error) -> ())?
    var loadedLinks = [String:Link]()
    lazy var sortAction: TargetAction = self.performSort()
    var scale: CGFloat!
    
    init(reddit: RedditController, path: String) {
        self.reddit = reddit
        self.path = path
        self.thumbnailService = ThumbnailService(source: reddit.reddit)
    }
    
    lazy var linksViewController: LinksViewController = { [unowned self] in
        let viewController = LinksViewController()
        viewController.title = self.path
        viewController.fetchNextPageAction = self.fetchNext
        viewController.fetchThumbnailAction = self.thumbnailService.load
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem.sort(self.sortAction)
        return viewController
    }()
    
    var viewController: UIViewController {
        return linksViewController
    }
    
    func performSort() -> TargetAction {
        return TargetAction { [unowned self] in
            let actionSheet = UIActionSheet(
                title: nil,
                delegate: self,
                cancelButtonTitle: "Cancel",
                destructiveButtonTitle: nil,
                otherButtonTitles: "Hot", "New", "Rising", "Controversial", "Top", "Gilded", "Promoted"
            )
            actionSheet.showInView(self.viewController.view)
        }
    }

    func cancelPromises() {
        linksPromise = nil
        thumbnailService.cancelPromises()
    }
    
    func fetchNext() {
        if let fetching = linksPromise {
            return
        }
        
        var query: [String:String] = [:]
        
        if let lastPage = linksViewController.pages.last {
            if let lastLink = lastPage.children.last {
                query = ["after": lastLink.name]
            }
        }
        
        linksPromise = fetchLinks(path, query: query).finally(self, { (context) in
            context.linksPromise = nil
        })
    }
    
    func fetchLinks(path: String, query: [String:String]) -> Promise<Listing<Link>> {
        return reddit.fetchReddit(path, query: query).when(self, { (controller, links) -> Result<Listing<Link>> in
            return .Deferred(controller.filterLinks(links, allowDups: false, allowOver18: false))
        }).when(self, { (controller, links) -> () in
            controller.linksViewController.addPage(links)
        }).catch(self, { (controller, error) in
            controller.linksError?(error: error)
            return
        })
    }
    
    func filterLinks(links: Listing<Link>, allowDups: Bool, allowOver18: Bool) -> Promise<Listing<Link>> {
        let promise = Promise<Listing<Link>>()
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
