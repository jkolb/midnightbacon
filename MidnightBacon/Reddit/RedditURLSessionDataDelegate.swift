//
//  RedditURLSessionDataDelegate.swift
//  MidnightBacon
//
// Copyright (c) 2015 Justin Kolb - http://franticapparatus.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation
import FranticApparatus
import Common

extension NSURLSession {
    public func mb_promise(request: NSURLRequest) -> Promise<URLResponse> {
        let promiseDelegate = delegate as! RedditURLSessionDataDelegate
        return promiseDelegate.URLSession(self, promiseForRequest: request)
    }
}

public class RedditURLSessionDataDelegate : NSObject, NSURLSessionDataDelegate {
    struct CallbacksAndData {
        let fulfill: (URLResponse) -> ()
        let reject: (ErrorType) -> ()
        let isCancelled: () -> Bool
        let data: NSMutableData
        
        var responseData: NSData {
            return data.copy() as! NSData
        }
    }
    
    var taskCallbacksAndData = Dictionary<NSURLSessionTask, CallbacksAndData>(minimumCapacity: 8)
    let lock = NSLock()
    
    private func synchronize(@noescape synchronized: () -> Void) {
        lock.lock()
        defer { lock.unlock() }
        synchronized()
    }

    func complete(task: NSURLSessionTask, error: NSError?) {
        synchronize {
            guard let callbacksAndData = taskCallbacksAndData[task] else { return }
            
            if error == nil {
                let value = URLResponse(metadata: task.response!, data: callbacksAndData.responseData)
                callbacksAndData.fulfill(value)
            } else {
                callbacksAndData.reject(error!)
            }
            
            taskCallbacksAndData[task] = nil
        }
    }
    
    func accumulate(task: NSURLSessionTask, data: NSData) {
        synchronize {
            guard let callbacksAndData = taskCallbacksAndData[task] else { return }
            
            if callbacksAndData.isCancelled() {
                task.cancel()
                taskCallbacksAndData[task] = nil
            } else {
                data.enumerateByteRangesUsingBlock { (bytes, range, stop) -> () in
                    callbacksAndData.data.appendBytes(bytes, length: range.length)
                }
            }
        }
    }
    
    func promise(session: NSURLSession, request: NSURLRequest) -> Promise<URLResponse> {
        return Promise<URLResponse> { (fulfill, reject, isCancelled) -> Void in
            guard let data = NSMutableData(capacity: 4096) else {
                reject(URLPromiseFactoryError.OutOfMemory)
                return
            }
            
            let dataTask = session.dataTaskWithRequest(request)

            synchronize {
                taskCallbacksAndData[dataTask] = CallbacksAndData(fulfill: fulfill, reject: reject, isCancelled: isCancelled, data: data)
            }
            
            dataTask.resume()
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
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
        if let url = request.URL {
            if let pathComponents = url.pathComponents {
                if pathComponents.count >= 3 && pathComponents.last == ".json" {
                    var fixedURL = url.URLByDeletingLastPathComponent!
                    let lastPathComponent = fixedURL.lastPathComponent!
                    fixedURL = fixedURL.URLByDeletingLastPathComponent!
                    fixedURL = fixedURL.URLByAppendingPathComponent(lastPathComponent, isDirectory: false)
                    fixedURL = fixedURL.URLByAppendingPathExtension("json")
                    let fixedRequest = task.originalRequest!.mutableCopy() as! NSMutableURLRequest
                    fixedRequest.URL = fixedURL
                    completionHandler(fixedRequest)
                    return
                }
            }
        }
        
        completionHandler(request)
    }
}
