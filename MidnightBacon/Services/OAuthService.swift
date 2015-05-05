//
//  OAuthService.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/18/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import FranticApparatus

class OAuthService {
    var redditRequest: RedditRequest!
    var insecureStore: InsecureStore!
    var secureStore: SecureStore!
    var gateway: Gateway!
    let clientID = "fnOncggIlO7nwA"
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
    
    func aquireAccessToken(forceRefresh: Bool = false) -> Promise<OAuthAccessToken> {
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
                return Result(strongSelf.refreshUserAccessToken(accessToken))
            } else {
                return Result(accessToken)
            }
        }).recover(self, { (strongSelf, reason) -> Result<OAuthAccessToken> in
            return Result(strongSelf.aquireApplicationAccessToken(forceRefresh))
        })
    }
    
    func aquireApplicationAccessToken(forceRefresh: Bool) -> Promise<OAuthAccessToken> {
        return secureStore.loadDeviceID().recover(self, { (strongSelf, reason) -> Result<NSUUID> in
            return Result(strongSelf.secureStore.saveDeviceID(NSUUID()))
        }).then(self, { (strongSelf, deviceID) -> Result<OAuthAccessToken> in
            return Result(strongSelf.aquireApplicationAccessTokenForDeviceID(deviceID, forceRefresh: forceRefresh))
        })
    }

    func aquireApplicationAccessTokenForDeviceID(deviceID: NSUUID, forceRefresh: Bool) -> Promise<OAuthAccessToken> {
        return secureStore.loadAccessTokenForDeviceID(deviceID).then(self, { (strongSelf, accessToken) -> Result<OAuthAccessToken> in
            if accessToken.isExpired || forceRefresh {
                return Result(strongSelf.generateApplicationAccessTokenForDeviceID(deviceID))
            } else {
                return Result(accessToken)
            }
        }).recover(self, { (strongSelf, reason) -> Result<OAuthAccessToken> in
            return Result(strongSelf.generateApplicationAccessTokenForDeviceID(deviceID))
        })
    }
    
    func generateApplicationAccessTokenForDeviceID(deviceID: NSUUID) -> Promise<OAuthAccessToken> {
        let installedClientRequest = redditRequest.applicationAccessToken(deviceID)
        return gateway.performRequest(installedClientRequest, session: nil).then(self, { (strongSelf, accessToken) -> Result<OAuthAccessToken> in
            return Result(strongSelf.secureStore.saveAccessToken(accessToken, forDeviceID: deviceID))
        })
    }
    
    func refreshUserAccessToken(accessToken: OAuthAccessToken) -> Promise<OAuthAccessToken> {
        let refreshTokenRequest = redditRequest.refreshAccessToken(accessToken)
        return gateway.performRequest(refreshTokenRequest, session: nil)
    }
}
