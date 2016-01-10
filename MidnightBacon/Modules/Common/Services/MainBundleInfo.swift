//
//  MainBundleInfo.swift
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

public enum BundleTypeRole : String {
    case Editor = "Editor"
    case Viewer = "Viewer"
    case Shell = "Shell"
    case None = "None"
}

public struct BundleURL {
    public let name: String
    public let role: BundleTypeRole
    public let schemes: [String]
    
    public func canAcceptURL(URL: NSURL) -> Bool {
        if role == .None { return false }
        return schemes.indexOf(URL.scheme) != nil
    }
    
    public static func fromURLType(dictionary: [String:AnyObject]) -> BundleURL {
        let name = dictionary["CFBundleURLName"] as? String ?? ""
        let role = BundleTypeRole(rawValue: dictionary["CFBundleTypeRole"] as? String ?? "") ?? BundleTypeRole.None
        let schemes = dictionary["CFBundleURLSchemes"] as? [String] ?? []
        return BundleURL(name: name, role: role, schemes: schemes)
    }
}

public protocol iOSBundleInfo {
    var displayName: String { get }
    var version: String { get }
    var build: String { get }
    var clientID: String { get }
    var userAgent: String { get }
    var redirectURI: String { get }
    func canAcceptURL(URL: NSURL) -> Bool
}

public class MainBundleInfo : iOSBundleInfo {
    let infoDictionary = NSBundle.mainBundle().infoDictionary!

    public init() { }
    
    public var displayName: String {
        return infoDictionary["CFBundleDisplayName"] as? String ?? ""
    }
    
    public var version: String {
        return infoDictionary["CFBundleShortVersionString"] as? String ?? ""
    }
    
    public var build: String {
        return infoDictionary["CFBundleVersion"] as? String ?? ""
    }
    
    public func canAcceptURL(URL: NSURL) -> Bool {
        for URLType in URLTypes {
            if URLType.canAcceptURL(URL) {
                return true
            }
        }
        return false
    }
    
    public var URLTypes: [BundleURL] {
        var types = [BundleURL]()
        let dictionaries = infoDictionary["CFBundleURLTypes"] as? [[String:AnyObject]] ?? []
        for dictionary in dictionaries {
            types.append(BundleURL.fromURLType(dictionary))
        }
        return types
    }
    
    public var clientID: String {
        return infoDictionary["com.franticapparatus.clientID"] as? String ?? ""
    }
    
    public var userAgent: String {
        return infoDictionary["com.franticapparatus.userAgent"] as? String ?? ""
    }
    
    public var redirectURI: String {
        return infoDictionary["com.franticapparatus.redirectURI"] as? String ?? ""
    }
}
