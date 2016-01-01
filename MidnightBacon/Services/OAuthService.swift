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
                    promise = aquireApplicationAccessToken(forceRefresh: forceRefresh)
                } else {
                    promise = aquireUserAccessToken(username, forceRefresh: forceRefresh)
                }
            } else {
                promise = aquireApplicationAccessToken(forceRefresh: forceRefresh)
            }
        }
        
        return promise
    }
    
    func aquireUserAccessToken(username: String, forceRefresh: Bool) -> Promise<OAuthAccessToken> {
        return secureStore.loadAccessTokenForUsername(username).thenWithContext(self, { (strongSelf, accessToken) -> Promise<OAuthAccessToken> in
            if accessToken.isExpired || forceRefresh {
                return strongSelf.refreshUserAccessToken(accessToken)
            } else {
                return Promise(accessToken)
            }
        }).recoverWithContext(self, { (strongSelf, reason) -> Promise<OAuthAccessToken> in
            return strongSelf.aquireApplicationAccessToken(forceRefresh: forceRefresh)
        })
    }
    
    func aquireApplicationAccessToken(forceRefresh forceRefresh: Bool) -> Promise<OAuthAccessToken> {
        return secureStore.loadDeviceID().recoverWithContext(self, { (strongSelf, reason) -> Promise<NSUUID> in
            return strongSelf.secureStore.saveDeviceID(NSUUID())
        }).thenWithContext(self, { (strongSelf, deviceID) -> Promise<OAuthAccessToken> in
            return strongSelf.aquireApplicationAccessTokenForDeviceID(deviceID, forceRefresh: forceRefresh)
        })
    }

    func aquireApplicationAccessTokenForDeviceID(deviceID: NSUUID, forceRefresh: Bool) -> Promise<OAuthAccessToken> {
        return secureStore.loadAccessTokenForDeviceID(deviceID).thenWithContext(self, { (strongSelf, accessToken) -> Promise<OAuthAccessToken> in
            if accessToken.isExpired || forceRefresh {
                return strongSelf.generateApplicationAccessTokenForDeviceID(deviceID)
            } else {
                return Promise(accessToken)
            }
        }).recoverWithContext(self, { (strongSelf, reason) -> Promise<OAuthAccessToken> in
            return strongSelf.generateApplicationAccessTokenForDeviceID(deviceID)
        })
    }
    
    func generateApplicationAccessTokenForDeviceID(deviceID: NSUUID) -> Promise<OAuthAccessToken> {
        let installedClientRequest = redditRequest.applicationAccessToken(deviceID)
        return gateway.performRequest(installedClientRequest).thenWithContext(self, { (strongSelf, accessToken) -> Promise<OAuthAccessToken> in
            return strongSelf.secureStore.saveAccessToken(accessToken, forDeviceID: deviceID)
        })
    }
    
    func refreshUserAccessToken(accessToken: OAuthAccessToken) -> Promise<OAuthAccessToken> {
        let refreshTokenRequest = redditRequest.refreshAccessToken(accessToken)
        return gateway.performRequest(refreshTokenRequest)
    }
}
