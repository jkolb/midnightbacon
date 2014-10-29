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
    var activityIndicator: UIActivityIndicatorView!
    var url: NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView()
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        view.addSubview(webView)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.color = GlobalStyle().redditOrangeRedColor
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        webView.loadRequest(NSURLRequest(URL: url))
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "estimatedProgress" {
            if webView.estimatedProgress >= 1.0 {
                activityIndicator.stopAnimating()
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        webView.frame = webView.layout(
            Left(equalTo: view.bounds.left),
            Top(equalTo: view.bounds.top),
            Width(equalTo: view.bounds.width),
            Height(equalTo: view.bounds.height)
        )
        
        activityIndicator.frame = activityIndicator.layout(
            CenterX(equalTo: view.bounds.centerX),
            CenterY(equalTo: view.bounds.centerY)
        )
    }
}
