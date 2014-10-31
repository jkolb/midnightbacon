//
//  Reddit.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/1/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus
import ModestProposal

class UnexpectedHTTPStatusCodeError : Error {
    let statusCode: Int
    
    init(_ statusCode: Int) {
        self.statusCode = statusCode
        super.init(message: "Status Code = \(statusCode)")
    }
}
class UnknownHTTPContentTypeError : Error { }
class UnexpectedHTTPContentTypeError : Error {
    let contentType: String
    
    init(_ contentType: String) {
        self.contentType = contentType
        super.init(message: "Content Type = " + contentType)
    }
}
class UnexpectedJSONError : Error { }
class UnexpectedImageFormatError: Error { }
class LoginError : Error {
    let errors: JSON
    
    init(_ errors: JSON) {
        self.errors = errors
        super.init(message: "Errors = \(errors)")
    }
}

class Reddit : HTTP, ImageSource {
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
        let permalink: String
    }
    
    struct Session {
        let modhash: String
        let cookie: String
        let needHTTPS: Bool
    }
    
    func promiseImage(url: NSURL) -> Promise<UIImage> {
        return promise(NSURLRequest(URL: url)).when { (response, data) -> Result<UIImage> in
            if response.statusCode != 200 {
                return .Failure(UnexpectedHTTPStatusCodeError(response.statusCode))
            }
            
            if let contentType = response.MIMEType {
                if contentType != "image/jpeg" && contentType != "image/png" && contentType != "image/gif" {
                    return .Failure(UnexpectedHTTPContentTypeError(contentType))
                }
            } else {
                return .Failure(UnknownHTTPContentTypeError())
            }
            
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
    
    func login(# username: String , password: String) -> Promise<Session> {
        let body = HTTP.formURLencoded(
            [
                "api_type": "json",
                "rem": "False",
                "passwd": password,
                "user": username,
            ]
        )
        return promisePOST(path: "/api/login", body: body).when { (response, data) in
            println(response)
            // 409 == Logged In ?
            if response.statusCode != 200 {
                return .Failure(UnexpectedHTTPStatusCodeError(response.statusCode))
            }
            
            if let contentType = response.MIMEType {
                if contentType != "application/json" {
                    return .Failure(UnexpectedHTTPContentTypeError(contentType))
                }
            } else {
                return .Failure(UnknownHTTPContentTypeError())
            }
            
            let promise = Promise<Session>()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [weak promise] in
                if let strongPromise = promise {
                    var error: NSError?
                    
                    if let json = JSON.parse(data, options: NSJSONReadingOptions(0), error: &error) {
                        println(json)
                        
                        if json[KeyPath("json.errors")].count > 0 {
                            strongPromise.reject(LoginError(json[KeyPath("json.errors")]))
                        } else {
                            let session = Session(
                                modhash: json[KeyPath("json.data.modhash")].string,
                                cookie: json[KeyPath("json.data.cookie")].string,
                                needHTTPS: json[KeyPath("json.data.need_https")].number.boolValue
                            )
                            strongPromise.fulfill(session)
                        }
                    } else {
                        strongPromise.reject(NSErrorWrapperError(cause: error!))
                    }
                }
            }
            return .Deferred(promise)
        }
    }
    
    func promiseJSON(path: String, query: [String:String] = [:]) -> Promise<JSON> {
        return promiseGET(path: path + ".json", query: query).when { (response, data) -> Result<JSON> in
            if response.statusCode != 200 {
                return .Failure(UnexpectedHTTPStatusCodeError(response.statusCode))
            }
            
            if let contentType = response.MIMEType {
                if contentType != "application/json" {
                    return .Failure(UnexpectedHTTPContentTypeError(contentType))
                }
            } else {
                return .Failure(UnknownHTTPContentTypeError())
            }
            
            let promise = Promise<JSON>()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [weak promise] in
                if let strongPromise = promise {
                    var error: NSError?
                    
                    if let json = JSON.parse(data, options: NSJSONReadingOptions(0), error: &error) {
                        strongPromise.fulfill(json)
                    } else {
                        strongPromise.reject(NSErrorWrapperError(cause: error!))
                    }
                }
            }
            return .Deferred(promise)
        }
    }
    
    func fetchReddit(path: String) -> Promise<Links> {
        let blockMapper = mapper
        return promiseJSON(path).when { (json) -> Result<Links> in
            return .Deferred(blockMapper.promiseLinks(json))
        }
    }
    
    class Mapper : Synchronizable {
        let synchronizationQueue: DispatchQueue = GCDQueue(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        
        func promiseLinks(json: JSON) -> Promise<Links> {
            let promise = Promise<Links>()
            synchronizeRead(self) { [weak promise] (mapper) in
                mapper.mapLinks(
                    json,
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
        
        func mapLinks(thing: JSON, isCancelled: @autoclosure () -> Bool, onMapped: (Links) -> (), onError: (Error) -> ()) {
//            println(thing)
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
                        commentCount: linkData["num_comments"].number.integerValue,
                        permalink: linkData["permalink"].string
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
