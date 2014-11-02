//
//  LinksViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FranticApparatus

class LinksViewController: UITableViewController, UIActionSheetDelegate {
    var linksPromise: Promise<Reddit.Links>!
    weak var applicationController: ApplicationController!
    weak var applicationStoryboard: ApplicationStoryboard!
    var links =  Reddit.Links.none()
    var thumbnails = [Int:UIImage]()
    var thumbnailPromises = [Int:Promise<UIImage>]()
    let thumbnailService = ThumbnailService<NSIndexPath>(source: Reddit())
    let textOnlyLinkSizingCell = TextOnlyLinkCell(style: .Default, reuseIdentifier: nil)
    let thumbnailLinkSizingCell = ThumbnailLinkCell(style: .Default, reuseIdentifier: nil)
    var cellHeightCache = [NSIndexPath:CGFloat]()
    
    struct Style {
        let backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        let foregroundColor = UIColor(white: 0.04, alpha: 1.0)
        let separatorColor = UIColor(white: 0.04, alpha: 0.2)
//        let backgroundColor = UIColor(white: 0.04, alpha: 1.0)
//        let foregroundColor = UIColor(white: 0.96, alpha: 1.0)
//        let separatorColor = UIColor(white: 0.96, alpha: 0.2)
//        let upvoteColor = UIColor(red: 0.98, green: 0.28, blue: 0.12, alpha: 1.0)
//        let downvoteColor = UIColor(red: 0.12, green: 0.28, blue: 0.98, alpha: 1.0)
        let upvoteColor = UIColor(red: 255.0/255.0, green: 139.0/255.0, blue: 96.0/255.0, alpha: 1.0) // ff8b60
        let downvoteColor = UIColor(red: 148.0/255.0, green: 148.0/255.0, blue: 255.0/255.0, alpha: 1.0) // 9494ff
    }
    
    let style = Style()
    
    func refreshLinks(links: Reddit.Links) {
        self.links = links
        tableView.reloadData()
    }
    
    func displayLinks(promise: Promise<Reddit.Links>) {
        linksPromise = promise.when({ [weak self] (links) -> () in
            self?.refreshLinks(links)
            return
        }).catch({ (error) -> () in
            println(error)
        }).finally({ [weak self] in
            self?.linksPromise = nil
            return
        })
    }
    
    func performSort() {
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Hot", "New", "Rising", "Controversial", "Top", "Gilded", "Promoted")
        actionSheet.showInView(view)
    }

    func showComments(link: Reddit.Link) {
        applicationStoryboard.showComments(link)
    }

    func configureThumbnailLinkCell(cell: ThumbnailLinkCell, link: Reddit.Link, indexPath: NSIndexPath) {
        cell.thumbnailImageView.image = thumbnailService.load(link.thumbnail, key: indexPath)
        cell.titleLabel.text = link.title
        cell.authorLabel.text = "\(link.author) · \(link.domain) · \(link.subreddit)"
        cell.commentsButton.setTitle("\(link.commentCount) comments", forState: .Normal)
        cell.commentsAction = { [weak self] in
            self?.showComments(link)
            return
        }
        
        if !cell.styled {
            styleThumbnailLinkCell(cell)
        }
    }
    
    func styleThumbnailLinkCell(cell: ThumbnailLinkCell) {
        cell.thumbnailImageView.layer.masksToBounds = true
        cell.thumbnailImageView.contentMode = .ScaleAspectFit
        cell.thumbnailImageView.layer.cornerRadius = 4.0
        cell.thumbnailImageView.layer.borderWidth = 1.0 / tableView.window!.screen.scale
        cell.thumbnailImageView.layer.borderColor = style.separatorColor.CGColor
        
        styleLinkCell(cell)
    }
    
    func configureTextOnlyLinkCell(cell: TextOnlyLinkCell, link: Reddit.Link, indexPath: NSIndexPath) {
        cell.titleLabel.text = link.title
        cell.authorLabel.text = "\(link.author) · \(link.domain) · \(link.subreddit)"
        cell.commentsButton.setTitle("\(link.commentCount) comments", forState: .Normal)
        cell.commentsAction = { [weak self] in
            self?.showComments(link)
            return
        }

        if !cell.styled {
            styleTextOnlyLinkCell(cell)
        }
    }
    
    func styleTextOnlyLinkCell(cell: TextOnlyLinkCell) {
        styleLinkCell(cell)
    }
    
    func styleLinkCell(cell: LinkCell) {
        cell.styled = true
        
        cell.backgroundColor = style.backgroundColor
        cell.contentView.backgroundColor = style.backgroundColor
        cell.selectionStyle = .None
        cell.layoutMargins = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
        
        cell.upvoteButton.setTitle("⬆︎", forState: .Normal)
        cell.upvoteButton.setTitleColor(style.upvoteColor, forState: .Normal)
        cell.upvoteButton.layer.cornerRadius = 4.0
        cell.upvoteButton.layer.borderWidth = 1.0
        cell.upvoteButton.layer.borderColor = style.upvoteColor.CGColor
        
        cell.downvoteButton.setTitle("⬆︎", forState: .Normal)
        cell.downvoteButton.transform = CGAffineTransformMakeScale(1.0, -1.0)
        cell.downvoteButton.setTitleColor(style.downvoteColor, forState: .Normal)
        cell.downvoteButton.layer.cornerRadius = 4.0
        cell.downvoteButton.layer.borderWidth = 1.0
        cell.downvoteButton.layer.borderColor = style.downvoteColor.CGColor
        
        cell.titleLabel.numberOfLines = 0
        cell.titleLabel.lineBreakMode = .ByTruncatingTail
        cell.titleLabel.textColor = style.foregroundColor
        cell.titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        
        cell.commentsButton.setTitleColor(GlobalStyle().redditUITextColor, forState: .Normal)
        cell.commentsButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        cell.commentsButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        
        cell.authorLabel.textColor = GlobalStyle().mediumColor
        cell.authorLabel.font = UIFont.systemFontOfSize(11.0)
        cell.authorLabel.lineBreakMode = .ByTruncatingTail
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(TextOnlyLinkCell.self, forCellReuseIdentifier: "TextOnlyLinkCell")
        tableView.registerClass(ThumbnailLinkCell.self, forCellReuseIdentifier: "ThumbnailLinkCell")
        tableView.backgroundColor = style.backgroundColor
        tableView.separatorColor = style.separatorColor
        
        thumbnailService.success = { [weak self] (image, indexPath) in
            if let blockSelf = self {
                if let cell = blockSelf.tableView.cellForRowAtIndexPath(indexPath) as? ThumbnailLinkCell {
                    cell.thumbnailImageView.image = image
                }
            }
        }
        thumbnailService.failure = { (error, indexPath) in
            println(error)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return links.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let link = links[indexPath.row]
        
        if link.hasThumbnail {
            let cell = tableView.dequeueReusableCellWithIdentifier("ThumbnailLinkCell", forIndexPath: indexPath) as ThumbnailLinkCell
            configureThumbnailLinkCell(cell, link: link, indexPath: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("TextOnlyLinkCell", forIndexPath: indexPath) as TextOnlyLinkCell
            configureTextOnlyLinkCell(cell, link: link, indexPath: indexPath)
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let cachedHeight = cellHeightCache[indexPath] {
            return cachedHeight
        } else {
            let link = links[indexPath.row]
            var cell: UITableViewCell!
            
            if link.hasThumbnail {
                configureThumbnailLinkCell(thumbnailLinkSizingCell, link: link, indexPath: indexPath)
                cell = thumbnailLinkSizingCell
            } else {
                configureTextOnlyLinkCell(textOnlyLinkSizingCell, link: link, indexPath: indexPath)
                cell = textOnlyLinkSizingCell
            }
            
            let availableWidth = tableView.bounds.width
            let size = cell.sizeThatFits(CGSize.fixedWidth(availableWidth))
            let height = size.height
            cellHeightCache[indexPath] = height
            return height
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let link = links[indexPath.row]

        var moreAction = UITableViewRowAction(style: .Normal, title: "More") { (action, indexPath) -> Void in
            tableView.editing = false
            let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: link.author, link.domain, link.subreddit, "Report", "Hide", "Share")
            actionSheet.showInView(self.view)
        }
        moreAction.backgroundColor = UIColor(red: 255.0/255.0, green: 87.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        
        return [moreAction]
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // If this isn't present the swipe doesn't work
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let link = links[indexPath.row]
        applicationStoryboard.displayLink(link)
    }
}
