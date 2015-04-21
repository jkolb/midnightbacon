//
//  KeychainStore.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/12/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus
import ModestProposal

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
    
    func loadCredential(username: String) -> Promise<NSURLCredential> {
        return Promise<NSURLCredential> { (fulfill, reject, isCancelled) in
            synchronizeRead(self) { (synchronizedSelf) in
                let result = synchronizedSelf.keychain.loadGenericPassword(service: "reddit_password", account: username)
                switch result {
                case .Success(let dataClosure):
                    let data = dataClosure.unwrap
                    
                    if let password = data.UTF8String {
                        let credential = NSURLCredential(user: username, password: password, persistence: .None)
                        fulfill(credential)
                    } else {
                        let credential = NSURLCredential(user: username, password: "", persistence: .None)
                        fulfill(credential)
                    }
                case .Failure(let error):
                    reject(NoCredentialError(cause: error))
                }
            }
        }
    }
    
    func loadSession(username: String) -> Promise<Session> {
        return Promise<Session> { (fulfill, reject, isCancelled) in
            synchronizeRead(self) { (synchronizedSelf) in
                let sessionResult = synchronizedSelf.keychain.loadGenericPassword(service: "reddit_session", account: username)
                switch sessionResult {
                case .Success(let dataClosure):
                    let data = dataClosure.unwrap
                    fulfill(Session.secureData(data))
                case .Failure(let error):
                    reject(NoSessionError(cause: error))
                }
            }
        }
    }
    
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

    func save(credential: NSURLCredential, _ session: Session) -> Promise<Bool> {
        return Promise<Bool> { (fulfill, reject, isCancelled) in
            synchronizeWrite(self) { (synchronizedSelf) in
                let username = credential.user!
                
                if let sessionData = session.secureData {
                    synchronizedSelf.keychain.saveGenericPassword(service: "reddit_session", account: username, data: sessionData)
                }
                
                if let passwordData = credential.secureData {
                    synchronizedSelf.keychain.saveGenericPassword(service: "reddit_password", account: username, data: passwordData)
                }
                
                fulfill(true)
            }
        }
    }
    
    func deleteSession(username: String) -> Promise<Bool> {
        return delete(service: "reddit_session", username: username)
    }
    
    func deleteCredential(username: String) -> Promise<Bool> {
        return delete(service: "reddit_password", username: username)
    }
    
    func delete(# service: String, username: String) -> Promise<Bool> {
        return Promise<Bool> { (fulfill, reject, isCancelled) in
            synchronizeWrite(self) { (synchronizedSelf) in
                let result = synchronizedSelf.keychain.deleteGenericPassword(service: service, account: username)
                switch result {
                case .Success:
                    fulfill(true)
                case .Failure(let error):
                    reject(NoSessionError(cause: error))
                }
            }
        }
    }
    
    func findUsernames() -> Promise<[String]> {
        return Promise<[String]> { (fulfill, reject, isCancelled) in
            synchronizeRead(self) { (synchronizedSelf) in
                let result = synchronizedSelf.keychain.findGenericPassword(service: "reddit_user_access_token") // reddit_password when using Session
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
