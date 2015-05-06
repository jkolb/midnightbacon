//
//  MainBundleInfo.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 2/28/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
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
        if let scheme = URL.scheme {
            return find(schemes, scheme) != nil
        } else {
            return false
        }
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
    func canAcceptURL(URL: NSURL) -> Bool
}

public class MainBundleInfo : iOSBundleInfo {
    let infoDictionary = NSBundle.mainBundle().infoDictionary as! [String:AnyObject]

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
}
