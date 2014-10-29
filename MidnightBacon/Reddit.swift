//
//  Reddit.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/1/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus
import ModestProposal

class UnexpectedJSONError : Error { }
class UnexpectedImageFormatError: Error { }

class Reddit : HTTP {
    struct Links {
        let links: [Link]
        let after: String
        let before: String
        let modhash: String
        
        static func none() -> Links {
            return Links(links: [], after: "", before: "", modhash: "")
        }
        
        var count: Int {
            return links.count
        }
        
        subscript(index: Int) -> Link {
            return links[index]
        }
    }
    
    struct Link {
        let title: String
        let url: NSURL
        let thumbnail: String
        let created: NSDate
        let author: String
        let domain: String
        let subreddit: String
        let commentCount: Int
    }
    
    func fetchImage(imageURL: NSURL) -> Promise<UIImage> {
        return fetchURL(imageURL).when { (data) -> Result<UIImage> in
            let promise = Promise<UIImage>()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [weak promise] in
                if let strongPromise = promise {
                    if let image = UIImage(data: data) {
                        strongPromise.fulfill(image)
                    } else {
                        strongPromise.reject(UnexpectedImageFormatError())
                    }
                }
            }
            return .Deferred(promise)
        }
    }
    
    let mapper = Mapper()
    
    func fetchReddit(path: String) -> Promise<Links> {
        let components = NSURLComponents()
        components.path = path + ".json"
        let blockMapper = mapper
        return fetchJSON(components).when { (data) -> Result<Links> in
            return .Deferred(blockMapper.promiseLinks(data))
        }
    }
    
    class Mapper : Synchronizable {
        let synchronizationQueue: DispatchQueue = GCDQueue(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        
        func promiseLinks(data: NSData) -> Promise<Links> {
            let promise = Promise<Links>()
            synchronizeRead(self) { [weak promise] (mapper) in
                mapper.mapLinks(
                    data,
                    isCancelled: promise == nil,
                    onMapped: { (links) in
                        if let strongPromise = promise {
                            strongPromise.fulfill(links)
                        }
                    },
                    onError: { (error) in
                        if let strongPromise = promise {
                            strongPromise.reject(error)
                        }
                    }
                )
            }
            return promise
        }
        
        func mapLinks(data: NSData, isCancelled: @autoclosure () -> Bool, onMapped: (Links) -> (), onError: (Error) -> ()) {
            var error: NSError?
            let json = JSON.parse(data, options: NSJSONReadingOptions(0), error: &error)

            if json == nil {
                onError(NSErrorWrapperError(cause: error!))
                return
            }

            let thing = json!
            println(thing)
            let kind = thing["kind"].string
            
            if kind != "Listing" {
                onError(UnexpectedJSONError(message: "Unexpected kind: " + kind))
                return
            }
            
            let listing = thing["data"]
            
            if listing.isNull {
                onError(UnexpectedJSONError(message: "Thing missing data"))
                return
            }

            let children = listing["children"]
            
            if !children.isArray {
                onError(UnexpectedJSONError(message: "Listing missing children"))
                return
            }

            if isCancelled() { return }

            var links = [Link]()
            
            for index in 0..<children.count {
                let childThing = children[index]
                let childKind = childThing["kind"].string
                
                if childKind != "t3" {
                    onError(UnexpectedJSONError(message: "Unexpected child kind: " + childKind))
                    return
                }
                
                let linkData = childThing["data"]
                
                if linkData.isNull {
                    onError(UnexpectedJSONError(message: "Child thing missing data"))
                    return
                }
                
                let url = linkData["url"].url
                
                if url == nil {
                    println("Skipped link due to invalid URL: " + linkData["url"].string)
                    continue
                }
                
                links.append(
                    Link(
                        title: linkData["title"].string,
                        url: url!,
                        thumbnail: linkData["thumbnail"].string,
                        created: linkData["created_utc"].date,
                        author: linkData["author"].string,
                        domain: linkData["domain"].string,
                        subreddit: linkData["subreddit"].string,
                        commentCount: linkData["num_comments"].number.integerValue
                    )
                )
            }
            
            onMapped(
                Links(
                    links: links,
                    after: listing["after"].string,
                    before: listing["before"].string,
                    modhash: listing["modhash"].string
                )
            )
        }
    }
}

extension JSON {
    var date: NSDate {
        return NSDate(timeIntervalSince1970: number.doubleValue)
    }
    
    var url: NSURL? {
        return string.length == 0 ? nil : NSURL(string: string)
    }
}
