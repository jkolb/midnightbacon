//
//  LinksController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

class LinksController : NSObject, Controller, UIActionSheetDelegate {
    let interactor: LinksInteractor
    let path: String
    var linksPromise: Promise<Listing<Link>>?
    lazy var sortAction: TargetAction = self.performSort()
    
    init(interactor: LinksInteractor, path: String) {
        self.interactor = interactor
        self.path = path
    }
    
    lazy var linksViewController: LinksViewController = { [unowned self] in
        let viewController = LinksViewController()
        viewController.title = self.path
        viewController.fetchNextPageAction = self.fetchNext
        viewController.loadThumbnailAction = self.loadThumbnail
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem.sort(self.sortAction)
        return viewController
    }()
    
    var viewController: UIViewController {
        return linksViewController
    }
    
    func performSort() -> TargetAction {
        return TargetAction { [unowned self] in
            let actionSheet = UIActionSheet(
                title: nil,
                delegate: self,
                cancelButtonTitle: "Cancel",
                destructiveButtonTitle: nil,
                otherButtonTitles: "Hot", "New", "Rising", "Controversial", "Top", "Gilded", "Promoted"
            )
            actionSheet.showInView(self.viewController.view)
        }
    }
    
    func fetchNext() {
        if let fetching = linksPromise {
            return
        }
        
        var query: [String:String] = [:]
        
        if let lastPage = linksViewController.pages.last {
            if let lastLink = lastPage.children.last {
                query = ["after": lastLink.name]
            }
        }
        
        linksPromise = interactor.fetchLinks(path, query: query).when(self, { (controller, links) -> () in
            controller.linksViewController.addPage(links)
        }).finally(self, { (controller) in
            controller.linksPromise = nil
        })
    }
    
    func loadThumbnail(thumbnail: String, key: NSIndexPath) -> UIImage? {
        return interactor.loadThumbnail(thumbnail, key: key, completion: { [weak self] (indexPath, image, error) -> () in
            if let controller = self {
                if let nonNilError = error {
                    
                } else if let nonNilImage = image {
                    controller.linksViewController.thumbnailLoaded(nonNilImage, indexPath: indexPath)
                }
            }
        })
    }
}
