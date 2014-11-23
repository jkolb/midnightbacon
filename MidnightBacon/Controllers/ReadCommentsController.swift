//
//  ReadCommentsController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/23/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class ReadCommentsController : Controller {
    var link: Link!
    lazy var webViewController: WebViewController = { [unowned self] in
        let viewController = WebViewController()
        viewController.title = "Comments"
        viewController.url = NSURL(string: "http://reddit.com\(self.link.permalink)")
        return viewController
    }()
    
    var viewController: UIViewController {
        return webViewController
    }
    
    init() {
    }
}
