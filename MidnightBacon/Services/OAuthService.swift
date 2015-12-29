//
//  OAuthService.swift
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

import FranticApparatus
import Common
import Reddit

class OAuthService {
    var gateway: Gateway!
    var redditRequest: RedditRequest!
    var insecureStore: InsecureStore!
    var secureStore: SecureStore!
    private var promise: Promise<OAuthAccessToken>!
    private var isResetting = false
    
    func lurkerMode() {
        insecureStore.lastAuthenticatedUsername = nil
        isResetting = true
    }
    
    func switchToUsername(username: String) {
        insecureStore.lastAuthenticatedUsername = username
        isResetting = true
    }
    
    func aquireAccessToken(forceRefresh forceRefresh: Bool = false) -> Promise<OAuthAccessToken> {
        if promise == nil || isResetting || forceRefresh {
            isResetting = false
            
            if let username = insecureStore.lastAuthenticatedUsername {
                if username.isEmpty {
                    promise = aquireApplicationAccessToken(forceRefresh)
                } else {
                    promise = aquireUserAccessToken(username, forceRefresh: forceRefresh)
                }
            } else {
                promise = aquireApplicationAccessToken(forceRefresh)
            }
        }
        
        return promise
    }
    
    func aquireUserAccessToken(username: String, forceRefresh: Bool) -> Promise<OAuthAccessToken> {
        return secureStore.loadAccessTokenForUsername(username).then(self, { (strongSelf, accessToken) -> Result<OAuthAccessToken> in
            if accessToken.isExpired || forceRefresh {
                return .Deferred(strongSelf.refreshUserAccessToken(accessToken))
            } else {
                return .Success(accessToken)
            }
        }).recover(self, { (strongSelf, reason) -> Result<OAuthAccessToken> in
            return .Deferred(strongSelf.aquireApplicationAccessToken(forceRefresh))
        })
    }
    
    func aquireApplicationAccessToken(forceRefresh forceRefresh: Bool) -> Promise<OAuthAccessToken> {
        return secureStore.loadDeviceID().recover(self, { (strongSelf, reason) -> Result<NSUUID> in
            return .Deferred(strongSelf.secureStore.saveDeviceID(NSUUID()))
        }).then(self, { (strongSelf, deviceID) -> Result<OAuthAccessToken> in
            return .Deferred(strongSelf.aquireApplicationAccessTokenForDeviceID(deviceID, forceRefresh: forceRefresh))
        })
    }

    func aquireApplicationAccessTokenForDeviceID(deviceID: NSUUID, forceRefresh: Bool) -> Promise<OAuthAccessToken> {
        return secureStore.loadAccessTokenForDeviceID(deviceID).then(self, { (strongSelf, accessToken) -> Result<OAuthAccessToken> in
            if accessToken.isExpired || forceRefresh {
                return .Deferred(strongSelf.generateApplicationAccessTokenForDeviceID(deviceID))
            } else {
                return .Success(accessToken)
            }
        }).recover(self, { (strongSelf, reason) -> Result<OAuthAccessToken> in
            return .Deferred(strongSelf.generateApplicationAccessTokenForDeviceID(deviceID))
        })
    }
    
    func generateApplicationAccessTokenForDeviceID(deviceID: NSUUID) -> Promise<OAuthAccessToken> {
        let installedClientRequest = redditRequest.applicationAccessToken(deviceID)
        return gateway.performRequest(installedClientRequest).then(self, { (strongSelf, accessToken) -> Result<OAuthAccessToken> in
            return .Deferred(strongSelf.secureStore.saveAccessToken(accessToken, forDeviceID: deviceID))
        })
    }
    
    func refreshUserAccessToken(accessToken: OAuthAccessToken) -> Promise<OAuthAccessToken> {
        let refreshTokenRequest = redditRequest.refreshAccessToken(accessToken)
        return gateway.performRequest(refreshTokenRequest)
    }
}
