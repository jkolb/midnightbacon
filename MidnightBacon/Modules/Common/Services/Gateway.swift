//
//  Gateway.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

protocol Gateway : ImageSource {
    func performRequest<T: APIRequest>(apiRequest: T) -> Promise<T.ResponseType>
    func performRequest<T: APIRequest>(apiRequest: T, accessToken: OAuthAccessToken) -> Promise<T.ResponseType>
}
