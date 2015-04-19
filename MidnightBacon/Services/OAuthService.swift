//
//  OAuthService.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/18/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import FranticApparatus

class OAuthService {
    var insecureStore: InsecureStore!
    var secureStore: SecureStore!
    var gateway: Gateway!
    let clientID = "fnOncggIlO7nwA"
    private var promise: Promise<OAuthAccessToken>!
    
    func aquireAccessToken() -> Promise<OAuthAccessToken> {
        if promise == nil {
            if let username = insecureStore.lastAuthenticatedUsername {
                if username.isEmpty {
                    promise = aquireApplicationAccessToken()
                } else {
                    promise = aquireUserAccessToken(username)
                }
            } else {
                promise = aquireApplicationAccessToken()
            }
        }
        
        return promise
    }
    
    func aquireUserAccessToken(username: String) -> Promise<OAuthAccessToken> {
        return secureStore.loadAccessTokenForUsername(username).then(self, { (strongSelf, accessToken) -> Result<OAuthAccessToken> in
            if accessToken.isExpired {
                return Result(strongSelf.refreshUserAccessToken(accessToken))
            } else {
                return Result(accessToken)
            }
        }).recover(self, { (strongSelf, reason) -> Result<OAuthAccessToken> in
            return Result(strongSelf.aquireApplicationAccessToken())
        })
    }
    
    func aquireApplicationAccessToken() -> Promise<OAuthAccessToken> {
        return secureStore.loadDeviceID().recover(self, { (strongSelf, reason) -> Result<NSUUID> in
            return Result(strongSelf.secureStore.saveDeviceID(NSUUID()))
        }).then(self, { (strongSelf, deviceID) -> Result<OAuthAccessToken> in
            return Result(strongSelf.aquireApplicationAccessTokenForDeviceID(deviceID))
        })
    }

    func aquireApplicationAccessTokenForDeviceID(deviceID: NSUUID) -> Promise<OAuthAccessToken> {
        return secureStore.loadAccessTokenForDeviceID(deviceID).recover(self, { (strongSelf, reason) -> Result<OAuthAccessToken> in
            return Result(strongSelf.generateApplicationAccessTokenForDeviceID(deviceID))
        })
    }
    
    func generateApplicationAccessTokenForDeviceID(deviceID: NSUUID) -> Promise<OAuthAccessToken> {
        let installedClientRequest = OAuthInstalledClientRequest(clientID: clientID, deviceID: deviceID)
        return gateway.performRequest(installedClientRequest, session: nil).then(self, { (strongSelf, accessToken) -> Result<OAuthAccessToken> in
            return Result(strongSelf.secureStore.saveAccessToken(accessToken, forDeviceID: deviceID))
        })
    }
    
    func refreshUserAccessToken(accessToken: OAuthAccessToken) -> Promise<OAuthAccessToken> {
        let refreshTokenRequest = OAuthRefreshTokenRequest(clientID: clientID, accessToken: accessToken)
        return gateway.performRequest(refreshTokenRequest, session: nil)
    }
}
