//
//  KeychainStore.swift
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
import ModestProposal
import Reddit
import Common
import Jasoom

public func transform<Input, Output>(
    on queue: DispatchQueue,
    input: Input,
    success: (Output) -> Void,
    failure: (ErrorType) -> Void,
    transformer: (Input) throws -> Output
    )
{
    queue.dispatch {
        do {
            success(try transformer(input))
        }
        catch {
            failure(error)
        }
    }
}

public func transform<Input, Output>(
    input input: Input,
    success: (Output) -> (),
    failure: (ErrorType) -> (),
    transformer: (Input) throws -> Output
    )
{
    transform(on: GCDQueue.globalPriorityDefault(), input: input, success: success, failure: failure, transformer: transformer)
}

enum KeychainStoreError : ErrorType {
    case InvalidAccessToken
}

class KeychainStore : SecureStore {
    var keychain = Keychain()
    
    func saveAccessToken(accessToken: OAuthAccessToken, forUsername username: String) -> Promise<OAuthAccessToken> {
        return Promise<OAuthAccessToken> { (fulfill, reject, isCancelled) -> Void in
            if accessToken.isValid {
                do {
                    let data = try OAuthAccessTokenMapper().map(accessToken)
                    try keychain.saveGenericPassword(service: "reddit_user_access_token", account: username, data: data)
                    fulfill(accessToken)
                }
                catch {
                    reject(error)
                }
            } else {
                reject(KeychainStoreError.InvalidAccessToken)
            }
        }
    }

    func loadAccessTokenForUsername(username: String) -> Promise<OAuthAccessToken> {
        return Promise<OAuthAccessToken> { (fulfill, reject, isCancelled) -> Void in
            do {
                let data = try keychain.loadGenericPassword(service: "reddit_user_access_token", account: username)
                transform(input: data, success: fulfill, failure: reject) { (data) throws -> OAuthAccessToken in
                    let json = try JSON.parseData(data)
                    
                    return try OAuthAccessTokenMapper().map(json)
                }
            }
            catch {
                reject(SecureStoreError.NoAccessToken)
            }
        }
    }

    func saveDeviceID(deviceID: NSUUID) -> Promise<NSUUID> {
        return Promise<NSUUID> { (fulfill, reject, isCancelled) -> Void in
            if let data = deviceID.UUIDString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                do {
                    try keychain.saveGenericPassword(service: "reddit_device_id", account: "reddit_device_id", data: data)
                    fulfill(deviceID)
                }
                catch {
                    reject(error)
                }
            } else {
                reject(SecureStoreError.InvalidDeviceIDData)
            }
        }
    }
    
    func loadDeviceID() -> Promise<NSUUID> {
        return Promise<NSUUID> { (fulfill, reject, isCancelled) -> Void in
            do {
                let data = try keychain.loadGenericPassword(service: "reddit_device_id", account: "reddit_device_id")
                
                if let string = data.UTF8String {
                    if let uuid = NSUUID(UUIDString: string) {
                        fulfill(uuid)
                    } else {
                        reject(SecureStoreError.InvalidDeviceIDData)
                    }
                } else {
                    reject(SecureStoreError.MissingDeviceIDData)
                }
            }
            catch {
                reject(SecureStoreError.UnableToReadDeviceID)
            }
        }
    }

    func saveAccessToken(accessToken: OAuthAccessToken, forDeviceID deviceID: NSUUID) -> Promise<OAuthAccessToken> {
        return Promise<OAuthAccessToken> { (fulfill, reject, isCancelled) -> Void in
            if accessToken.isValid {
                do {
                    let data = try OAuthAccessTokenMapper().map(accessToken)
                    try keychain.saveGenericPassword(service: "reddit_application_access_token", account: deviceID.UUIDString, data: data)
                    fulfill(accessToken)
                }
                catch {
                    reject(error)
                }
            } else {
                reject(KeychainStoreError.InvalidAccessToken)
            }
        }
    }
    
    func loadAccessTokenForDeviceID(deviceID: NSUUID) -> Promise<OAuthAccessToken> {
        return Promise<OAuthAccessToken> { (fulfill, reject, isCancelled) -> Void in
            do {
                let data = try keychain.loadGenericPassword(service: "reddit_application_access_token", account: deviceID.UUIDString)
                transform(input: data, success: fulfill, failure: reject) { (data) throws -> OAuthAccessToken in
                    let json = try JSON.parseData(data)
                    
                    return try OAuthAccessTokenMapper().map(json)
                }
            }
            catch {
                reject(SecureStoreError.NoAccessToken)
            }
        }
    }
    
    func delete(service service: String, username: String) -> Promise<Bool> {
        return Promise<Bool> { (fulfill, reject, isCancelled) -> Void in
            do {
                try keychain.deleteGenericPassword(service: service, account: username)
                fulfill(true)
            }
            catch {
                reject(error)
            }
        }
    }
    
    func findUsernames() -> Promise<[String]> {
        return Promise<[String]> { (fulfill, reject, isCancelled) -> Void in
            do {
                let items = try keychain.findGenericPassword(service: "reddit_user_access_token")
                var usernames = [String]()
                
                for item in items {
                    if let username = item.account {
                        usernames.append(username)
                    }
                }
                
                fulfill(usernames)
            }
            catch {
                reject(error)
            }
        }
    }
}
