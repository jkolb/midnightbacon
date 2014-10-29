//
//  WebViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/29/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import WebKit

class WebViewController : UIViewController {
    var webView: WKWebView!
    var url: NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView()
        view.addSubview(webView)
        
        webView.loadRequest(NSURLRequest(URL: url))
    }
    
    override func viewWillLayoutSubviews() {
        webView.frame = webView.layout(
            Left(equalTo: view.bounds.left),
            Top(equalTo: view.bounds.top),
            Width(equalTo: view.bounds.width),
            Height(equalTo: view.bounds.height)
        )
    }
}
