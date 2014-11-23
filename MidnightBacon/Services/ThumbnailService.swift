//
//  File.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/30/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

class InvalidThumbnailError : Error {
    let thumbnail: String
    
    init(_ thumbnail: String) {
        self.thumbnail = thumbnail
        super.init(message: "Invalid thumbnail: \(thumbnail)")
    }
}

class ThumbnailService {
    var promises = [String:Promise<UIImage>]()
    let source: ImageSource
    let cache: NSCache = NSCache()
    
    init(source: ImageSource) {
        self.source = source
    }
    
    func hasPromised(thumbnail: String) -> Bool {
        return promises[thumbnail] != nil
    }
    
    func cancelPromises() {
        promises.removeAll(keepCapacity: true)
    }
    
    func load(thumbnail: String, key: NSIndexPath, completion: (NSIndexPath, UIImage?, Error?) -> ()) -> UIImage? {
        if thumbnail == "nsfw" {
            return UIImage(named: "thumbnail_nsfw")
        } else if thumbnail == "self" {
            return UIImage(named: "thumbnail_self")
        } else if thumbnail == "default" {
            return UIImage(named: "thumbnail_default")
        } else if let image: AnyObject = cache.objectForKey(thumbnail) {
            return image as? UIImage
        } else if hasPromised(thumbnail) {
            return UIImage(named: "thumbnail_default")
        } else {
            promise(thumbnail, key: key, completion: completion)
            return UIImage(named: "thumbnail_default")
        }
    }
    
    func promise(thumbnail: String, key: NSIndexPath, completion: (NSIndexPath, UIImage?, Error?) -> ()) {
        if let url = NSURL(string: thumbnail) {
            promises[thumbnail] = source.requestImage(url).when(self, { (service, image) -> () in
                service.cache.setObject(image, forKey: thumbnail)
                completion(key, image, nil)
            }).catch({ (error) in
                completion(key, nil, error)
            }).finally(self, { (context) in
                context.promises[thumbnail] = nil
            })
        } else {
            promises[thumbnail] = Promise<UIImage>().catch({ (error) in
                completion(key, nil, error)
            }).finally(self, { (context) in
                context.promises[thumbnail] = nil
            })
            promises[thumbnail]!.reject(InvalidThumbnailError(thumbnail))
        }
    }
}
