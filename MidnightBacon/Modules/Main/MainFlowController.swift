//
//  MainFlowController.swift
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
import Common

class MainFlowController : TabFlowController {
    weak var factory: MainFactory!
    var debugFlowController: DebugFlowController!
    var subredditsFlowController: SubredditsFlowController!
    var accountsFlowController: AccountsFlowController!
    var messagesFlowController: MessagesFlowController!
    var tabController: TabBarController!
    
    override func loadViewController() {
        tabController = TabBarController()
        tabBarController = tabController // Fix this!
        viewController = tabController
    }
    
    override func viewControllerDidLoad() {
        tabBarController.delegate = self
        tabBarController.viewControllers = [
            startSubredditsFlow(),
            startMessagesFlow(),
            startAccountsFlow(),
        ]
    }
    
    func startSubredditsFlow() -> UIViewController {
        subredditsFlowController = factory.subredditsFlowController()
        
        let viewController = subredditsFlowController.start()
        viewController.title = "Subreddits"
        viewController.tabBarItem = UITabBarItem(title: "Subreddits", image: UIImage(named: "subreddits_unselected"), selectedImage: UIImage(named: "subreddits_selected"))
        return viewController
    }
    
    func startAccountsFlow() -> UIViewController {
        accountsFlowController = factory.accountsFlowController()
        
        let viewController = accountsFlowController.start()
        viewController.title = "Accounts"
        viewController.tabBarItem = UITabBarItem(title: "Accounts", image: UIImage(named: "accounts_unselected"), selectedImage: UIImage(named: "accounts_selected"))
        return viewController
    }
    
    func startMessagesFlow() -> UIViewController {
        messagesFlowController = factory.messagesFlowController()
        
        let viewController = messagesFlowController.start()
        viewController.title = "Messages"
        viewController.tabBarItem = UITabBarItem(title: "Messages", image: UIImage(named: "messages_unselected"), selectedImage: UIImage(named: "messages_selected"))
        return viewController
    }
}

extension MainFlowController : TabBarControllerDelegate {
    func tabBarControllerDidDetectShake(tabBarController: TabBarController) {
        if debugFlowController == nil {
            debugFlowController = DebugFlowController()
            debugFlowController.factory = factory
            debugFlowController.delegate = self
        }
        
        if debugFlowController.canStart {
            presentAndStartFlow(debugFlowController, animated: true, completion: nil)
        }
    }
}

extension MainFlowController : DebugFlowControllerDelegate {
    func debugFlowControllerDidCancel(debugFlowController: DebugFlowController) {
        debugFlowController.stopAnimated(true) { [weak self] in
            self?.debugFlowController = nil
        }
    }
}
