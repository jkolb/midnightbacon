//
//  OAuthFlow.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 2/25/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation

class OAuthFlow : NSObject, OAuthDelegate {
    var oauth: OAuth!
    var presenter: Presenter!
    var oauthFactory: OAuthFactory!
    
    func present() {
        oauth.requestAccess()
    }
    
    func cancel() {
        presenter.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func oauthRequestAccess(oauth: OAuth, url: NSURL) {
        let viewController = oauthFactory.oauthNavigationViewController(url)
        presenter.presentViewController(viewController, animated: true, completion: nil)
    }
}
