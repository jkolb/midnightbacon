//
//  OAuthAuthorizationCodeRequest.swift
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

class OAuthAuthorizationCodeRequest : APIRequest {
    let mapperFactory: RedditFactory
    let prototype: NSURLRequest
    let grantType: OAuthGrantType
    let clientID: String
    let authorizeResponse: OAuthAuthorizeResponse
    let redirectURI: NSURL
    
    init(mapperFactory: RedditFactory, prototype: NSURLRequest, clientID: String, authorizeResponse: OAuthAuthorizeResponse, redirectURI: NSURL) {
        self.mapperFactory = mapperFactory
        self.prototype = prototype
        self.grantType = .AuthorizationCode
        self.clientID = clientID
        self.authorizeResponse = authorizeResponse
        self.redirectURI = redirectURI
    }
    
    typealias ResponseType = OAuthAccessToken
    
    func parse(response: URLResponse) -> Outcome<OAuthAccessToken, Error> {
        let mapperFactory = self.mapperFactory
        return redditJSONMapper(response) { (json) -> Outcome<OAuthAccessToken, Error> in
            return mapperFactory.accessTokenMapper().map(json)
        }
    }

    func build() -> NSMutableURLRequest {
        let request = prototype.POST(
            "/api/v1/access_token",
            parameters: [
                "grant_type": grantType.rawValue,
                "code": authorizeResponse.code,
                "redirect_uri": redirectURI.absoluteString!,
            ]
        )
        request.basicAuthorization(username: clientID, password: "")
        return request
    }
    
    var requiresModhash : Bool {
        return false
    }
    
    var scope : OAuthScope? {
        return nil
    }
}
