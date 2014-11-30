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
    let style: Style
    let cache: NSCache = NSCache()
    
    init(source: ImageSource, style: Style) {
        self.source = source
        self.style = style
    }
    
    func hasPromised(thumbnail: String) -> Bool {
        return promises[thumbnail] != nil
    }
    
    func cancelPromises() {
        promises.removeAll(keepCapacity: true)
    }
    
    func load(thumbnail: String, key: NSIndexPath, completion: (NSIndexPath, UIImage?, Error?) -> ()) -> UIImage? {
        if let image: AnyObject = cache.objectForKey(thumbnail) {
            return image as? UIImage
        } else if thumbnail == "nsfw" {
            return localThumbnail(thumbnail, named: "thumbnail_nsfw")
        } else if thumbnail == "self" {
            return localThumbnail(thumbnail, named: "thumbnail_self")
        } else if thumbnail == "default" {
            return localThumbnail(thumbnail, named: "thumbnail_default")
        } else if hasPromised(thumbnail) {
            return localThumbnail("default", named: "thumbnail_default")
        } else {
            promise(thumbnail, key: key, completion: completion)
            return localThumbnail("default", named: "thumbnail_default")
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
    
    func localThumbnail(thumbnail: String, named: String) -> UIImage? {
        if let image: AnyObject = cache.objectForKey(thumbnail) {
            return image as? UIImage
        }
        
        let tintedOrNil = UIImage(named: named)?.tinted(style.redditNeutralColor)
        
        if let tinted = tintedOrNil {
            cache.setObject(tinted, forKey: thumbnail)
            return tinted
        } else {
            return nil
        }
    }
}
