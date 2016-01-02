//
//  SubredditsFlowController.swift
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
import Reddit
import Common

enum SubredditMenuEvent {
    case ShowSubredditLinks(title: String, path: String)
    case ShowPopularSubreddits
    case ShowNewSubreddits
}

class SubredditsFlowController : NavigationFlowController {
    weak var factory: MainFactory!
    var submitFlowController: SubmitFlowController!
    var currentSubreddit: String?
    
    func openLinks(title title: String, path: String) {
        let viewController = factory.linksViewController(title: title, path: path)
        currentSubreddit = path
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem.compose(
            style: factory.style(),
            target: self,
            action: "composeSpecificSubreddit"
        )
        viewController.delegate = self
        pushViewController(viewController)
    }
    
    func composeUnknownSubreddit() {
        submitFlowController = SubmitFlowController()
        submitFlowController.factory = factory
        submitFlowController.delegate = self
        presentAndStartFlow(submitFlowController, animated: true, completion: nil)
    }
    
    func composeSpecificSubreddit() {
        submitFlowController = SubmitFlowController()
        submitFlowController.factory = factory
        submitFlowController.subreddit = currentSubreddit
        submitFlowController.delegate = self
        presentAndStartFlow(submitFlowController, animated: true, completion: nil)
    }
    
    func clearBackButtonTitle(viewController: UIViewController) {
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    override func viewControllerDidLoad() {
        let viewController = buildMenuViewController()
        pushViewController(viewController, animated: false)
    }
    
    override func willShow(viewController: UIViewController, animated: Bool) {
        clearBackButtonTitle(viewController)
    }
    
    
    func handleSubredditMenuEvent(event: SubredditMenuEvent) {
        switch event {
        case .ShowSubredditLinks(let title, let path):
            openLinks(title: title, path: path)
        case .ShowPopularSubreddits:
            factory.logger().debug("popular")
        case .ShowNewSubreddits:
            factory.logger().debug("new")
        }
    }
    
    func build() -> Menu<SubredditMenuEvent> {
        let menu = Menu<SubredditMenuEvent>()
        
        menu.addGroup("Subreddits")
        menu.addNavigationItem("Front", event: .ShowSubredditLinks(title: "Front", path: "/"))
        menu.addNavigationItem("All", event: .ShowSubredditLinks(title: "All", path: "/r/all"))
        menu.addNavigationItem("Random", event: .ShowSubredditLinks(title: "Random", path: "/r/random"))
        menu.addNavigationItem("Popular", event: .ShowPopularSubreddits)
        menu.addNavigationItem("New", event: .ShowNewSubreddits)
        
        menu.addGroup("My Subreddits")
        menu.addNavigationItem("iOSProgramming", event: .ShowSubredditLinks(title: "iOSProgramming", path: "/r/iOSProgramming"))
        menu.addNavigationItem("Swift", event: .ShowSubredditLinks(title: "Swift", path: "/r/Swift"))
        menu.addNavigationItem("Programming", event: .ShowSubredditLinks(title: "Programming", path: "/r/Programming"))
        menu.addNavigationItem("movies", event: .ShowSubredditLinks(title: "movies", path: "/r/movies"))
        menu.addNavigationItem("Minecraft", event: .ShowSubredditLinks(title: "Minecraft", path: "/r/Minecraft"))
        menu.addNavigationItem("redditdev", event: .ShowSubredditLinks(title: "redditdev", path: "/r/redditdev"))
        
        menu.eventHandler = handleSubredditMenuEvent
        
        return menu
    }

    // MARK: View Controller Factory
    
    func buildMenuViewController() -> MenuViewController {
        let viewController = MenuViewController()
        viewController.title = "Subreddits"
        viewController.menu = build()
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem.compose(
            style: factory.style(),
            target: self,
            action: "composeUnknownSubreddit"
        )
        return viewController
    }
}

extension SubredditsFlowController : LinksViewControllerDelegate {
    func linksViewController(linksViewController: LinksViewController, displayLink link: Link) {
        let viewController = factory.readLinkViewController(link)
        pushViewController(viewController)
    }
    
    func linksViewController(linksViewController: LinksViewController, showCommentsForLink link: Link) {
        let viewController = factory.commentsViewController(link)
        viewController.title = "Comments"
        pushViewController(viewController)
    }
    
    func linksViewController(linksViewController: LinksViewController, voteForLink link: Link, direction: VoteDirection) {
        
    }
}

extension SubredditsFlowController : SubmitFlowControllerDelegate {
    func submitFlowController(submitFlowController: SubmitFlowController, didTriggerAction action: SubmitFlowControllerAction) {
        submitFlowController.stopAnimated(true) { [weak self] in
            if let strongSelf = self {
                strongSelf.submitFlowController = nil
            }
        }
    }
}
