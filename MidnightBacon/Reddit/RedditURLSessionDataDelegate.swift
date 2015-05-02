//
//  RedditURLSessionDataDelegate.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/28/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation
import FranticApparatus

extension NSURLSession : URLPromiseFactory {
    public func promise(request: NSURLRequest) -> Promise<URLResponse> {
        let promiseDelegate = delegate as! RedditURLSessionDataDelegate
        return promiseDelegate.URLSession(self, promiseForRequest: request)
    }
}

public class RedditURLSessionDataDelegate : NSObject, NSURLSessionDataDelegate, Synchronizable {
    struct CallbacksAndData {
        let fulfill: (URLResponse) -> ()
        let reject: (Error) -> ()
        let isCancelled: () -> Bool
        let data: NSMutableData
        
        var responseData: NSData {
            return data.copy() as! NSData
        }
    }
    
    var callbacksAndData = Dictionary<NSURLSessionTask, CallbacksAndData>(minimumCapacity: 8)
    public let synchronizationQueue: DispatchQueue = GCDQueue.concurrent("net.franticapparatus.PromiseSession")
    
    func complete(task: NSURLSessionTask, error: NSError?) {
        synchronizeRead(self) { (delegate) in
            if let callbacksAndData = delegate.callbacksAndData[task] {
                if error == nil {
                    let value = URLResponse(metadata: task.response!, data: callbacksAndData.responseData)
                    callbacksAndData.fulfill(value)
                } else {
                    let reason = NSErrorWrapperError(cause: error!)
                    callbacksAndData.reject(reason)
                }
            }
            
            synchronizeWrite(delegate) { (delegate) in
                delegate.callbacksAndData[task] = nil
            }
        }
    }
    
    func accumulate(task: NSURLSessionTask, data: NSData) {
        synchronizeWrite(self) { (delegate) in
            if let callbacksAndData = delegate.callbacksAndData[task] {
                if callbacksAndData.isCancelled() {
                    task.cancel()
                    delegate.callbacksAndData[task] = nil
                } else {
                    data.enumerateByteRangesUsingBlock { (bytes, range, stop) -> () in
                        callbacksAndData.data.appendBytes(bytes, length: range.length)
                    }
                }
            }
        }
    }
    
    func promise(session: NSURLSession, request: NSURLRequest) -> Promise<URLResponse> {
        return Promise<URLResponse> { (fulfill, reject, isCancelled) -> () in
            let threadSafeRequest = request.copy() as! NSURLRequest
            
            synchronizeWrite(self) { (delegate) in
                if isCancelled() {
                    return;
                }
                
                if let data = NSMutableData(capacity: 4096) {
                    let dataTask = session.dataTaskWithRequest(threadSafeRequest)
                    let callbacksAndData = CallbacksAndData(fulfill: fulfill, reject: reject, isCancelled: isCancelled, data: data)
                    delegate.callbacksAndData[dataTask] = callbacksAndData
                    dataTask.resume()
                } else {
                    reject(OutOfMemoryError())
                }
            }
        }
    }
    
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        accumulate(dataTask, data: data)
    }
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        complete(task, error: error)
    }
    
    public func URLSession(session: NSURLSession, promiseForRequest request: NSURLRequest) -> Promise<URLResponse> {
        return promise(session, request: request)
    }
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest!) -> Void) {
        if let url = request.URL {
            if var pathComponents = url.pathComponents as? [String] {
                if pathComponents.count >= 3 && pathComponents.last == ".json" {
                    var fixedURL = url.URLByDeletingLastPathComponent!
                    var lastPathComponent = fixedURL.lastPathComponent!
                    fixedURL = fixedURL.URLByDeletingLastPathComponent!
                    fixedURL = fixedURL.URLByAppendingPathComponent(lastPathComponent, isDirectory: false)
                    fixedURL = fixedURL.URLByAppendingPathExtension("json")
                    let fixedRequest = task.originalRequest.mutableCopy() as! NSMutableURLRequest
                    fixedRequest.URL = fixedURL
                    completionHandler(fixedRequest)
                    return
                }
            }
        }
        
        completionHandler(request)
    }
}
