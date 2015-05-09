//
//  SubmitDataController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 5/9/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import FranticApparatus
import Common
import Reddit

class SubmitDataController {
    var redditRequest: RedditRequest!
    var oauthService: OAuthService!
    var gateway: Gateway!
    
    func sendSubmitForm(form: SubmitForm, completion: (Error?) -> ()) {
        completion(nil)
    }
}
