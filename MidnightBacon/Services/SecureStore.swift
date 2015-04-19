//
//  SecureStore.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/9/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

protocol SecureStore {
    func saveDeviceID(deviceID: NSUUID) -> Promise<NSUUID>
    func loadDeviceID() -> Promise<NSUUID>

    func saveAccessToken(accessToken: OAuthAccessToken, forDeviceID deviceID: NSUUID) -> Promise<OAuthAccessToken>
    func loadAccessTokenForDeviceID(deviceID: NSUUID) -> Promise<OAuthAccessToken>

    func saveAccessToken(accessToken: OAuthAccessToken, forUsername username: String) -> Promise<OAuthAccessToken>
    func loadAccessTokenForUsername(username: String) -> Promise<OAuthAccessToken>
    
    func save(credential: NSURLCredential, _ session: Session) -> Promise<Bool>
    func loadCredential(username: String) -> Promise<NSURLCredential>
    func loadSession(username: String) -> Promise<Session>
    func deleteSession(username: String) -> Promise<Bool>
    func deleteCredential(username: String) -> Promise<Bool>
    func findUsernames() -> Promise<[String]>
}

class NoCredentialError : Error {
    let cause: Error
    
    init(cause: Error) {
        self.cause = cause
        super.init(message: cause.description)
    }
}

class NoSessionError : Error  {
    let cause: Error
    
    init(cause: Error) {
        self.cause = cause
        super.init(message: cause.description)
    }
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
