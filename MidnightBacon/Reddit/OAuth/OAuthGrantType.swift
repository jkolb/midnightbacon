//
//  OAuthGrantType.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 1/7/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

enum OAuthGrantType : String {
    case AuthorizationCode = "authorization_code"
    case RefreshToken = "refresh_token"
    // Installed app types (as these apps are considered "non-confidential", have no secret, and thus, are ineligible for client_credentials grant.
    case InstalledClient = "https://oauth.reddit.com/grants/installed_client"
    // Confidential clients (web apps / scripts) not acting on behalf of one or more logged out users.
    case ClientCredentials = "client_credentials"
}
