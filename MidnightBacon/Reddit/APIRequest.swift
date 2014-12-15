//
//  RequestBuilder.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/14/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

enum APIType : String {
    case JSON = "json"
    case XML = "xml"
}

protocol APIRequest {
    func build(builder: HTTPRequestBuilder) -> NSMutableURLRequest
    var requiresModhash : Bool { get }
    var scope : OAuthScope? { get }
}

extension String {
    init?(_ value: Int?) {
        if let nonNilValue = value {
            self.init(nonNilValue)
        } else {
            return nil
        }
    }
}
