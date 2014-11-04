//
//  File.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/30/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

protocol ImageSource {
    func requestImage(url: NSURL) -> Promise<UIImage>
}

class InvalidThumbnailError : Error {
    let thumbnail: String
    
    init(_ thumbnail: String) {
        self.thumbnail = thumbnail
        super.init(message: "Invalid thumbnail: \(thumbnail)")
    }
}

class ThumbnailService {
    var promises = [NSIndexPath:Promise<UIImage>]()
    let source: ImageSource
    var success: ((image: UIImage, key: NSIndexPath) -> ())?
    var failure: ((error: Error, key: NSIndexPath) -> ())?
    let cache: NSCache = NSCache()
    
    init(source: ImageSource) {
        self.source = source
    }
    
    func hasPromised(key: NSIndexPath) -> Bool {
        return promises[key] != nil
    }
    
    func load(thumbnail: String, key: NSIndexPath) -> UIImage? {
        if thumbnail == "nsfw" {
            return UIImage(named: "thumbnail_nsfw")
        } else if thumbnail == "self" {
            return UIImage(named: "thumbnail_self")
        } else if thumbnail == "default" {
            return UIImage(named: "thumbnail_default")
        } else if let image: AnyObject = cache.objectForKey(key) {
            return image as? UIImage
        } else if hasPromised(key) {
            return UIImage(named: "thumbnail_default")
        } else {
            promise(thumbnail, key: key)
            return UIImage(named: "thumbnail_default")
        }
    }
    
    func promise(thumbnail: String, key: NSIndexPath) {
        if let url = NSURL(string: thumbnail) {
            promises[key] = source.requestImage(url).when({ [weak self] (image) in
                if let blockSelf = self {
                    blockSelf.cache.setObject(image, forKey: key)
                    
                    if let success = blockSelf.success {
                        success(image: image, key: key)
                    }
                }
            }).catch({ [weak self] (error) in
                if let blockSelf = self {
                    if let failure = blockSelf.failure {
                        failure(error: error, key: key)
                    }
                }
            }).finally({ [weak self] in
                if let blockSelf = self {
                    blockSelf.promises[key] = nil
                }
            })
        } else {
            promises[key] = Promise<UIImage>().catch({ [weak self] (error) in
                if let blockSelf = self {
                    if let failure = blockSelf.failure {
                        failure(error: error, key: key)
                    }
                }
            }).finally({ [weak self] in
                if let blockSelf = self {
                    blockSelf.promises[key] = nil
                }
            })
            promises[key]!.reject(InvalidThumbnailError(thumbnail))
        }
    }
}
