//
//  File.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/30/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

class ThumbnailService {
    var promises = [NSURL:Promise<UIImage>]()
    let source: ImageSource
    let style: Style
    let cache: NSCache = NSCache()
    
    init(source: ImageSource, style: Style) {
        self.source = source
        self.style = style
    }
    
    func cancelPromises() {
        promises.removeAll(keepCapacity: true)
    }
    
    func load(thumbnail: Thumbnail, key: NSIndexPath, completion: (NSIndexPath, Outcome<UIImage, Error>) -> ()) -> UIImage? {
        if let image = imageForThumbnail(thumbnail) { return image }
        
        switch thumbnail {
        case .URL(let thumbnailURL):
            promise(thumbnailURL, key: key, completion: completion)
            return builtin(.Default)
        case .BuiltIn(let type):
            return builtin(type)
        }
    }
    
    func promise(thumbnailURL: NSURL, key: NSIndexPath, completion: (NSIndexPath, Outcome<UIImage, Error>) -> ()) {
        let alreadyPromised = (promises[thumbnailURL] != nil)
        if alreadyPromised { return }
        
        promises[thumbnailURL] = source.requestImage(thumbnailURL).when(self, { (service, image) -> () in
            service.cache(image, forThumbnail: Thumbnail.URL(thumbnailURL))
            completion(key, .Success(image))
        }).catch({ (error) in
            completion(key, .Failure(error))
        }).finally(self, { (context) in
            context.promises[thumbnailURL] = nil
        })
    }
    
    func builtin(type: BuiltInType) -> UIImage? {
        let thumbnail = Thumbnail.BuiltIn(type)
        if let image = imageForThumbnail(thumbnail) { return image }
        if let tinted = UIImage(named: "thumbnail_\(type.rawValue)")?.tinted(style.redditNeutralColor) {
            cache(tinted, forThumbnail: thumbnail)
            return tinted
        } else {
            return nil
        }
    }
    
    func cache(image: UIImage, forThumbnail thumbnail: Thumbnail) {
        cache.setObject(image, forKey: thumbnail.stringValue)
    }
    
    func imageForThumbnail(thumbnail: Thumbnail) -> UIImage? {
        if let object: AnyObject = cache.objectForKey(thumbnail.stringValue) {
            return object as? UIImage
        } else {
            return nil
        }
    }
}
