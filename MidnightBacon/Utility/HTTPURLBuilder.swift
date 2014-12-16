//
//  HTTPURLBuilder.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/16/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

class HTTPURLBuilder {
    let baseURL: NSURL
    
    convenience init(secure: Bool, host: String, path: String? = nil, port: Int? = nil) {
        let baseComponents = NSURLComponents()
        baseComponents.scheme = secure ? "https" : "http"
        baseComponents.host = host
        baseComponents.path = path
        baseComponents.port = port
        
        if let URL = baseComponents.URL {
            self.init(baseURL: URL)
        } else {
            fatalError("Invalid URL")
        }
    }
    
    init(baseURL: NSURL) {
        self.baseURL = baseURL
    }

    func URL(# path: String?, query: [String:String]? = nil, fragment: String? = nil) -> NSURL? {
        return self.dynamicType.URL(baseURL: baseURL, path: path, query: query, fragment: fragment)
    }
    
    class func URL(# baseURL: NSURL, path pathOrNil: String?, query: [String:String]? = nil, fragment: String? = nil) -> NSURL? {
        if let components = NSURLComponents(URL: baseURL, resolvingAgainstBaseURL: true) {
            if let path = pathOrNil {
                components.path?.extend(path)
            }
            
            components.queryItems = queryItems(query: query)
            components.fragment = fragment
            
            return components.URL
        } else {
            return nil
        }
    }
    
    class func queryItems(query queryOrNil: [String:String]?) -> [NSURLQueryItem]? {
        if let query = queryOrNil {
            var queryItems = [NSURLQueryItem]()
            for (name, value) in query {
                queryItems.append(NSURLQueryItem(name: name, value: value))
            }
            return queryItems
        } else {
            return nil
        }
    }
}
