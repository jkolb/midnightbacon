//
//  LinksController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class LinksController : NSObject, Controller, UIActionSheetDelegate {
    let interactor: LinksInteractor
    let path: String
    lazy var sortAction: TargetAction = self.performSort()
    var showCommentsAction: ((Link) -> ())!
    var showLinkAction: ((Link) -> ())!

    init(interactor: LinksInteractor, path: String) {
        self.interactor = interactor
        self.path = path
    }
    
    lazy var linksViewController: LinksViewController = { [unowned self] in
        let viewController = LinksViewController()
        viewController.title = self.path
        viewController.fetchNextPageAction = self.fetchNext
        viewController.loadThumbnailAction = self.loadThumbnail
        viewController.showCommentsAction = self.showCommentsAction
        viewController.showLinkAction = self.showLinkAction
        return viewController
    }()
    
    var viewController: UIViewController {
        return linksViewController
    }
    
    func performSort() -> TargetAction {
        return action(self) { (context) in
            let actionSheet = UIActionSheet(
                title: nil,
                delegate: self,
                cancelButtonTitle: "Cancel",
                destructiveButtonTitle: nil,
                otherButtonTitles: "Hot", "New", "Rising", "Controversial", "Top", "Gilded", "Promoted"
            )
            actionSheet.showInView(context.viewController.view)
        }
    }
    
    func fetchNext() {
        var query: [String:String] = [:]
        
        if let lastPage = linksViewController.pages.last {
            if let lastLink = lastPage.children.last {
                query = ["after": lastLink.name]
            }
        }
        
        interactor.fetchLinks(path, query: query) { [weak self] (links, error) in
            if let controller = self {
                if let nonNilError = error {
                    // Do nothing for now
                } else if let nonNilLinks = links {
                    controller.linksViewController.addPage(nonNilLinks)
                }
            }
        }
    }
    
    func loadThumbnail(thumbnail: String, key: NSIndexPath) -> UIImage? {
        return interactor.loadThumbnail(thumbnail, key: key) { [weak self] (indexPath, image, error) -> () in
            if let controller = self {
                if let nonNilError = error {
                    // Do nothing for now
                } else if let nonNilImage = image {
                    controller.linksViewController.thumbnailLoaded(nonNilImage, indexPath: indexPath)
                }
            }
        }
    }
}
