//
//  OAuthAccessTokenRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/17/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

class OAuthAccessTokenRequest : APIRequest {
    let authorizeResponse: OAuthAuthorizeResponse
    let clientID: String
    let redirectURI: NSURL
    
    init(authorizeResponse: OAuthAuthorizeResponse, clientID: String, redirectURI: NSURL) {
        self.authorizeResponse = authorizeResponse
        self.clientID = clientID
        self.redirectURI = redirectURI
    }
    
    func build(builder: HTTPRequestBuilder) -> NSMutableURLRequest {
        var parameters = [String:String](minimumCapacity: 4)
        parameters["grant_type"] = "authorization_code"
        parameters["code"] = authorizeResponse.code
        parameters["redirect_uri"] = redirectURI.absoluteString!
        let request = builder.POST("/api/v1/access_token", parameters: parameters)
        let authorizationString = "\(clientID):"
        if let authorizationData = authorizationString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            let base64String = authorizationData.base64EncodedDataWithOptions(NSDataBase64EncodingOptions(0))
            request.setValue("Basic \(base64String):", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    var requiresModhash : Bool {
        return false
    }
    
    var scope : OAuthScope? {
        return nil
    }
}
