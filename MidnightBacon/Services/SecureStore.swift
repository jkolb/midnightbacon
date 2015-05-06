//
//  SecureStore.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/9/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus
import Reddit

protocol SecureStore {
    func saveDeviceID(deviceID: NSUUID) -> Promise<NSUUID>
    func loadDeviceID() -> Promise<NSUUID>

    func saveAccessToken(accessToken: OAuthAccessToken, forDeviceID deviceID: NSUUID) -> Promise<OAuthAccessToken>
    func loadAccessTokenForDeviceID(deviceID: NSUUID) -> Promise<OAuthAccessToken>

    func saveAccessToken(accessToken: OAuthAccessToken, forUsername username: String) -> Promise<OAuthAccessToken>
    func loadAccessTokenForUsername(username: String) -> Promise<OAuthAccessToken>
    
    func findUsernames() -> Promise<[String]>
}

class NoAccessTokenError : Error {
    let cause: Error
    
    init(cause: Error) {
        self.cause = cause
        super.init(message: cause.description)
    }
}

class DeviceIDReadError : Error {
    let cause: Error
    
    init(cause: Error) {
        self.cause = cause
        super.init(message: cause.description)
    }
}

class MissingDeviceIDDataError : Error {}
class InvalidDeviceIDDataError : Error {}
