//
//  OAuthInstalledClientRequest.swift
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
import ModestProposal
import FranticApparatus
import Common

class OAuthInstalledClientRequest : APIRequest {
    let mapperFactory: RedditFactory
    let prototype: NSURLRequest
    let grantType: OAuthGrantType
    let clientID: String
    let deviceID: NSUUID
    
    init(mapperFactory: RedditFactory, prototype: NSURLRequest, clientID: String, deviceID: NSUUID) {
        self.mapperFactory = mapperFactory
        self.prototype = prototype
        self.grantType = .InstalledClient
        self.clientID = clientID
        self.deviceID = deviceID
    }
    
    typealias ResponseType = OAuthAccessToken
    
    func parse(response: URLResponse) throws -> OAuthAccessToken {
        return try redditJSONMapper(response) { (json) -> OAuthAccessToken in
            return try mapperFactory.accessTokenMapper().map(json)
        }
    }
    
    func build() -> NSMutableURLRequest {
        let request = prototype.POST(
            path: "/api/v1/access_token",
            parameters: [
                "grant_type": grantType.rawValue,
                "device_id": deviceID.UUIDString,
            ]
        )
        try! request.basicAuthorization(username: clientID, password: "")
        return request
    }
    
    var requiresModhash : Bool {
        return false
    }
    
    var scope : OAuthScope? {
        return nil
    }
}
