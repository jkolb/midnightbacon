//
//  RequestBuilder.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/14/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation
import ModestProposal
import FranticApparatus

enum APIType : String {
    case JSON = "json"
    case XML = "xml"
}

protocol APIRequest {
    typealias ResponseType
    func parse(response: URLResponse, mapperFactory: RedditFactory) -> Outcome<ResponseType, Error>
    func build(prototype: NSURLRequest) -> NSMutableURLRequest
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
    
    init?(_ value: Bool?) {
        if let nonNilValue = value {
            if nonNilValue {
                self.init("true")
            } else {
                self.init("false")
            }
        } else {
            return nil
        }
    }
}
