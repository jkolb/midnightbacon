//
//  WebViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/29/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import WebKit
import DrapierLayout

class WebViewController : UIViewController, WKNavigationDelegate {
    var style: Style!
    var webView: WKWebView!
    var activityIndicator: UIActivityIndicatorView!
    var url: NSURL!
    var currentNavigation: WKNavigation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView()
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.color = style.redditOrangeRedColor
        view.addSubview(activityIndicator)
        
        currentNavigation = webView.loadRequest(NSURLRequest(URL: url))
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
    
    // MARK: - WKNavigationDelegate
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        NSLog("decidePolicyForNavigationAction: %@ %@", navigationAction.navigationType.stringValue, navigationAction)
        decisionHandler(.Allow)
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
        NSLog("decidePolicyForNavigationResponse: %@", navigationResponse)
        decisionHandler(.Allow)
    }
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        NSLog("didStartProvisionalNavigation: %@", navigation)
        activityIndicator.startAnimating()
    }
    
    func webView(webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        NSLog("didReceiveServerRedirectForProvisionalNavigation: %@", navigation)
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        NSLog("didFailProvisionalNavigation:withError: %@ %@", navigation, error)
        activityIndicator.stopAnimating()
    }
    
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        NSLog("didCommitNavigation: %@", navigation)
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        NSLog("didFinishNavigation: %@", navigation)
        activityIndicator.stopAnimating()
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        NSLog("didFailNavigation:withError: %@ %@", navigation, error)
        activityIndicator.stopAnimating()
    }
}

extension WKNavigationType {
    var stringValue: String {
        switch self {
        case .BackForward:
            return "BackForward"
        case .FormResubmitted:
            return "FormResubmitted"
        case .FormSubmitted:
            return "FormSubmitted"
        case .LinkActivated:
            return "LinkActivated"
        case .Other:
            return "Other"
        case .Reload:
            return "Reload"
        }
    }
}
