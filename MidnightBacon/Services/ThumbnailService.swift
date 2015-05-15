//
//  File.swift
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

import UIKit
import FranticApparatus
import ModestProposal
import Common
import Reddit

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
            return nil
        case .BuiltIn(let type):
            return builtin(type)
        }
    }
    
    func promise(thumbnailURL: NSURL, key: NSIndexPath, completion: (NSIndexPath, Outcome<UIImage, Error>) -> ()) {
        let alreadyPromised = (promises[thumbnailURL] != nil)
        if alreadyPromised { return }
        
        promises[thumbnailURL] = source.requestImage(thumbnailURL).then(self, { (service, image) -> () in
            service.cache(image, forThumbnail: Thumbnail.URL(thumbnailURL))
            completion(key, Outcome(image))
        }).catch({ (error) in
            completion(key, Outcome(error))
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
