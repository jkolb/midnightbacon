//
//  ReadLinkController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/23/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class ReadLinkController : Controller {
    var link: Link!
    lazy var webViewController: WebViewController = { [unowned self] in
        let viewController = WebViewController()
        viewController.title = "Link"
        viewController.url = self.link.url
        return viewController
    }()
    
    var viewController: UIViewController {
        return webViewController
    }
    
    init() {
    }
}
