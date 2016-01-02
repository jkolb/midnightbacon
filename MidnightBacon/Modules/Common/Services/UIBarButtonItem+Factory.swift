//
//  UIBarButtonItem+Factory.swift
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

extension UIBarButtonItem {
    public class func edit(target target: AnyObject?, action: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .Edit, target: target, action: action)
    }
    
    public class func done(target target: AnyObject?, action: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .Done, target: target, action: action)
    }
    
    public class func cancel(target target: AnyObject?, action: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .Cancel, target: target, action: action)
    }
    
    public class func submit(target target: AnyObject?, action: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(title: "Submit", style: .Plain, target: target, action: action)
    }
    
    public class func compose(style style: Style, target: AnyObject?, action: Selector) -> UIBarButtonItem {
        let image = UIImage(named: "compose")!.tinted(style.redditUITextColor)
        return UIBarButtonItem(image: image, style: .Plain, target: target, action: action)
    }
}
