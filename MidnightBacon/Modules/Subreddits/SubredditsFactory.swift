//
//  SubredditsFactory.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/4/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FieryCrucible

class SubredditsFactory : DependencyFactory {
    var sharedFactory: SharedFactory!
    
    func subredditsFlow() -> SubredditsFlow {
        return shared(
            "subredditsFlow",
            factory: SubredditsFlow(),
            configure: { [unowned self] (instance) in
                instance.subredditsFactory = self
                instance.styleFactory = self.sharedFactory
            }
        )
    }
    
    func linksViewController(# title: String, path: String) -> LinksViewController {
        return scoped(
            "linksViewController",
            factory: LinksViewController(),
            configure: { [unowned self] (instance) in
                instance.title = title
                instance.path = path
                instance.style = self.sharedFactory.style()
                instance.interactor = self.linksInteractor()
            }
        )
    }
    
    func linksInteractor() -> LinksInteractor {
        return unshared(
            "linksInteractor",
            factory: LinksInteractor(),
            configure: { [unowned self] (instance) in
                instance.gateway = self.sharedFactory.gateway()
                instance.sessionService = self.sharedFactory.sessionService()
                instance.thumbnailService = self.sharedFactory.thumbnailService()
            }
        )
    }
    
    func readLinkViewController(link: Link) -> WebViewController {
        return scoped(
            "readLinkViewController",
            factory: WebViewController(),
            configure: { [unowned self] (instance) in
                instance.style = self.sharedFactory.style()
                instance.title = "Link"
                instance.url = link.url
                instance.webViewConfiguration = self.sharedFactory.webViewConfiguration()
            }
        )
    }
    
    func readCommentsViewController(link: Link) -> WebViewController {
        return scoped(
            "readCommentsViewController",
            factory: WebViewController(),
            configure: { [unowned self] (instance) in
                instance.style = self.sharedFactory.style()
                instance.title = "Comments"
                instance.url = NSURL(string: "http://reddit.com/comments/\(link.id)")
                instance.webViewConfiguration = self.sharedFactory.webViewConfiguration()
            }
        )
    }
}
