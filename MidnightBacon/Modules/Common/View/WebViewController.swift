//
//  WebViewController.swift
//  MidnightBacon
//
// Copyright (c) 2015 Justin Kolb - http://franticapparatus.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import UIKit
import WebKit
import DrapierLayout
import Common

protocol WebViewControllerDelegate : class {
    func webViewController(viewController: WebViewController, handleApplicationURL URL: NSURL)
}

class WebViewController : UIViewController, WKNavigationDelegate {
    var style: Style!
    var webView: WKWebView!
    var webViewConfiguration: WKWebViewConfiguration!
    var activityIndicator: UIActivityIndicatorView!
    var url: NSURL!
    var logger: Logger?
    var currentNavigation: WKNavigation?
    weak var delegate: WebViewControllerDelegate?
    var bundleInfo: iOSBundleInfo = MainBundleInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView(frame: CGRectZero, configuration: webViewConfiguration)
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.color = style.redditOrangeRedColor
        view.addSubview(activityIndicator)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if currentNavigation == nil {
            currentNavigation = webView.loadRequest(NSURLRequest(URL: url))
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
    
    // MARK: - WKNavigationDelegate
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        logger?.debug("\(__FUNCTION__) \(navigationAction.navigationType.stringValue) \(navigationAction)")
        decisionHandler(.Allow)
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
        logger?.debug("\(__FUNCTION__) \(navigationResponse)")
        decisionHandler(.Allow)
    }
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        logger?.debug("\(__FUNCTION__) \(navigation)")
        activityIndicator.startAnimating()
    }
    
    func webView(webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        logger?.debug("\(__FUNCTION__) \(navigation)")
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        logger?.debug("\(__FUNCTION__) \(navigation) \(error)")
        activityIndicator.stopAnimating()
        
        if error.domain == NSURLErrorDomain && error.code == NSURLErrorUnsupportedURL {
            if let failingURL = error.userInfo["NSErrorFailingURLKey"] as? NSURL {
                if bundleInfo.canAcceptURL(failingURL) {
                    if let delegate = self.delegate {
                        delegate.webViewController(self, handleApplicationURL: failingURL)
                        return
                    }
                }
            }
        }
        
        let alertView = UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK")
        alertView.show()
    }
    
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        logger?.debug("\(__FUNCTION__) \(navigation)")
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        logger?.debug("\(__FUNCTION__) \(navigation)")
        activityIndicator.stopAnimating()
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        logger?.debug("\(__FUNCTION__) \(navigation) \(error)")
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
