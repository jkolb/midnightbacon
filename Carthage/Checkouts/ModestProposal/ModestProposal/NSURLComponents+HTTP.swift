// Copyright (c) 2016 Justin Kolb - http://franticapparatus.net
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

import Foundation

public extension NSURLComponents {
    public var parameters: [String:String] {
        get {
            // Assumes query string does not have duplicate names! Last duplicate processed will overwrite any prior values.
            if let items = queryItems {
                var parameters = [String:String](minimumCapacity: items.count)
                for item in items {
                    parameters[item.name] = item.value
                }
                return parameters
            } else {
                return [:]
            }
        }
        set {
            if newValue.count == 0 {
                queryItems = nil
            } else {
                var items = [NSURLQueryItem]()
                items.reserveCapacity(newValue.count)
                for (name, value) in newValue {
                    items.append(NSURLQueryItem(name: name, value: value))
                }
                queryItems = items
            }
        }
    }
}
