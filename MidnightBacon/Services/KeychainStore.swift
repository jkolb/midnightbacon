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

public func transform<Input, Output>(
    on queue: DispatchQueue,
    # input: Input,
    # success: (Output) -> (),
    # failure: (Error) -> (),
    transformer: (Input) -> Outcome<Output, Error>
    )
{
    queue.dispatch {
        switch transformer(input) {
        case .Success(let valueWrapper):
            success(valueWrapper.unwrap)
        case .Failure(let errorWrapper):
            failure(errorWrapper.unwrap)
        }
    }
}

public func transform<Input, Output>(
    # input: Input,
    # success: (Output) -> (),
    # failure: (Error) -> (),
    transformer: (Input) -> Outcome<Output, Error>
    )
{
    transform(on: GCDQueue.globalPriorityDefault(), input: input, success: success, failure: failure, transformer)
}

class KeychainStore : SecureStore, Synchronizable {
    let synchronizationQueue: DispatchQueue = GCDQueue.concurrent("net.franticapparatus.KeychainStore")
    var keychain = Keychain()
    
    func saveAccessToken(accessToken: OAuthAccessToken, forUsername username: String) -> Promise<OAuthAccessToken> {
        return Promise<OAuthAccessToken> { (fulfill, reject, isCancelled) in
            synchronizeWrite(self) { (synchronizedSelf) in
                if accessToken.isValid {
                    let data = OAuthAccessTokenMapper().map(accessToken)
                    let result = synchronizedSelf.keychain.saveGenericPassword(service: "reddit_user_access_token", account: username, data: data)
                    switch result {
                    case .Success:
                        fulfill(accessToken)
                    case .Failure(let error):
                        reject(error)
                    }
                } else {
                    reject(Error(message: "Invalid access token"))
                }
            }
        }
    }

    func loadAccessTokenForUsername(username: String) -> Promise<OAuthAccessToken> {
        return Promise<OAuthAccessToken> { (fulfill, reject, isCancelled) in
            synchronizeRead(self) { (synchronizedSelf) in
                let result = synchronizedSelf.keychain.loadGenericPassword(service: "reddit_user_access_token", account: username)
                switch result {
                case .Success(let dataWrapper):
                    let data = dataWrapper.unwrap
                    transform(input: data, success: fulfill, failure: reject) { (data) -> Outcome<OAuthAccessToken, Error> in
                        var error: NSError?
                        if let json = JSON.parse(data, options: nil, error: &error) {
                            return OAuthAccessTokenMapper().map(json)
                        } else {
                            return Outcome(NSErrorWrapperError(cause: error!))
                        }
                    }
                case .Failure(let error):
                    reject(NoAccessTokenError(cause: error))
                }
            }
        }
    }

    func saveDeviceID(deviceID: NSUUID) -> Promise<NSUUID> {
        return Promise<NSUUID> { (fulfill, reject, isCancelled) in
            synchronizeWrite(self) { (synchronizedSelf) in
                if let data = deviceID.UUIDString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                    let result = synchronizedSelf.keychain.saveGenericPassword(service: "reddit_device_id", account: "reddit_device_id", data: data)
                    switch result {
                    case .Success:
                        fulfill(deviceID)
                    case .Failure(let error):
                        reject(error)
                    }
                } else {
                    reject(InvalidDeviceIDDataError())
                }
            }
        }
    }
    
    func loadDeviceID() -> Promise<NSUUID> {
        return Promise<NSUUID> { (fulfill, reject, isCancelled) in
            synchronizeRead(self) { (synchronizedSelf) in
                let sessionResult = synchronizedSelf.keychain.loadGenericPassword(service: "reddit_device_id", account: "reddit_device_id")
                switch sessionResult {
                case .Success(let dataWrapper):
                    let data = dataWrapper.unwrap
                    
                    if let string = data.UTF8String {
                        if let uuid = NSUUID(UUIDString: string) {
                            fulfill(uuid)
                        } else {
                            reject(InvalidDeviceIDDataError())
                        }
                    } else {
                        reject(MissingDeviceIDDataError())
                    }
                case .Failure(let error):
                    reject(DeviceIDReadError(cause: error))
                }
            }
        }
    }

    func saveAccessToken(accessToken: OAuthAccessToken, forDeviceID deviceID: NSUUID) -> Promise<OAuthAccessToken> {
        return Promise<OAuthAccessToken> { (fulfill, reject, isCancelled) in
            synchronizeWrite(self) { (synchronizedSelf) in
                if accessToken.isValid {
                    let data = OAuthAccessTokenMapper().map(accessToken)
                    let result = synchronizedSelf.keychain.saveGenericPassword(service: "reddit_application_access_token", account: deviceID.UUIDString, data: data)
                    switch result {
                    case .Success:
                        fulfill(accessToken)
                    case .Failure(let error):
                        reject(error)
                    }
                } else {
                    reject(Error(message: "Invalid access token"))
                }
            }
        }
    }
    
    func loadAccessTokenForDeviceID(deviceID: NSUUID) -> Promise<OAuthAccessToken> {
        return Promise<OAuthAccessToken> { (fulfill, reject, isCancelled) in
            synchronizeRead(self) { (synchronizedSelf) in
                let result = synchronizedSelf.keychain.loadGenericPassword(service: "reddit_application_access_token", account: deviceID.UUIDString)
                switch result {
                case .Success(let dataWrapper):
                    let data = dataWrapper.unwrap
                    transform(input: data, success: fulfill, failure: reject) { (data) -> Outcome<OAuthAccessToken, Error> in
                        var error: NSError?
                        if let json = JSON.parse(data, options: nil, error: &error) {
                            return OAuthAccessTokenMapper().map(json)
                        } else {
                            return Outcome(NSErrorWrapperError(cause: error!))
                        }
                    }
                case .Failure(let error):
                    reject(NoAccessTokenError(cause: error))
                }
            }
        }
    }
    
    func delete(# service: String, username: String) -> Promise<Bool> {
        return Promise<Bool> { (fulfill, reject, isCancelled) in
            synchronizeWrite(self) { (synchronizedSelf) in
                let result = synchronizedSelf.keychain.deleteGenericPassword(service: service, account: username)
                switch result {
                case .Success:
                    fulfill(true)
                case .Failure(let error):
                    reject(NoAccessTokenError(cause: error))
                }
            }
        }
    }
    
    func findUsernames() -> Promise<[String]> {
        return Promise<[String]> { (fulfill, reject, isCancelled) in
            synchronizeRead(self) { (synchronizedSelf) in
                let result = synchronizedSelf.keychain.findGenericPassword(service: "reddit_user_access_token")
                switch result {
                case .Success(let itemsClosure):
                    let items = itemsClosure.unwrap
                    var usernames = [String]()
                    
                    for item in items {
                        if let username = item.account {
                            usernames.append(username)
                        }
                    }
                    
                    fulfill(usernames)
                case .Failure(let error):
                    reject(error)
                }
            }
        }
    }
}
