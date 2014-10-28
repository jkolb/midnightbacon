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
    var links =  Reddit.Links.none()
    var thumbnails = [Int:UIImage]()
    var thumbnailPromises = [Int:Promise<UIImage>]()
    let reddit = Reddit(baseURL: NSURL(string: "http://www.reddit.com/")!)

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 140.0 // This depends on the size of the dynamic text!
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerClass(LinkCell.self, forCellReuseIdentifier: "LinkCell")
        tableView.registerClass(ThumbnailLinkCell.self, forCellReuseIdentifier: "ThumbnailLinkCell")
        tableView.backgroundColor = style.backgroundColor
        tableView.separatorColor = style.separatorColor
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return links.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let link = links[indexPath.row]
        
        if let thumbnailURL = link.thumbnailURL {
            let cell = tableView.dequeueReusableCellWithIdentifier("ThumbnailLinkCell", forIndexPath: indexPath) as ThumbnailLinkCell
            
            cell.titleLabel.text = link.title
            cell.authorLabel.text = "\(link.author) · \(link.domain) · \(link.subreddit)"
            cell.commentsButton.setTitle("\(link.commentCount)", forState: .Normal)
            
            if let thumbnail = thumbnails[indexPath.row] {
                cell.thumbnailImageView.image = thumbnail
            } else {
                let thumbnailData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("placeholderThumbnail", ofType: "jpg")!)
                let thumbnail = UIImage(data: thumbnailData!, scale: 2.0)
                cell.thumbnailImageView.image = thumbnail
                
                if let thumbnailPromise = thumbnailPromises[indexPath.row] {
                    
                } else {
                    let promise = reddit.fetchImage(thumbnailURL).when { [weak self] (image) in
                        if let blockSelf = self {
                            blockSelf.thumbnails[indexPath.row] = image
                            
                            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                                if let thumbnailCell = cell as? ThumbnailLinkCell {
                                    thumbnailCell.thumbnailImageView.image = image
                                }
                            }
                        }
                    }
                    thumbnailPromises[indexPath.row] = promise
                }
            }
            
            if !cell.configured {
                cell.configured = true
                
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
                
                cell.thumbnailImageView.layer.masksToBounds = true
                cell.thumbnailImageView.layer.cornerRadius = 4.0
                cell.thumbnailImageView.layer.borderWidth = 1.0 / tableView.window!.screen.scale
                cell.thumbnailImageView.layer.borderColor = style.separatorColor.CGColor
                
                cell.commentsButton.setTitleColor(style.separatorColor, forState: .Normal)
                cell.commentsButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 8.0)
                cell.commentsButton.layer.cornerRadius = 4.0
                cell.commentsButton.layer.borderWidth = 1.0
                cell.commentsButton.layer.borderColor = style.separatorColor.CGColor
                cell.commentsButton.titleLabel?.font = UIFont.systemFontOfSize(11.0)
                
                cell.authorLabel.textColor = style.separatorColor
                cell.authorLabel.font = UIFont.systemFontOfSize(11.0)
                cell.authorLabel.lineBreakMode = .ByTruncatingTail
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("LinkCell", forIndexPath: indexPath) as LinkCell
            
            cell.titleLabel.text = link.title
            cell.authorLabel.text = "\(link.author) · \(link.domain) · \(link.subreddit)"
            cell.commentsButton.setTitle("\(link.commentCount)", forState: .Normal)
            
            if !cell.configured {
                cell.configured = true
                
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
                cell.titleLabel.font = UIFont.systemFontOfSize(14.0)
                
                cell.commentsButton.setTitleColor(style.separatorColor, forState: .Normal)
                cell.commentsButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 8.0)
                cell.commentsButton.layer.cornerRadius = 4.0
                cell.commentsButton.layer.borderWidth = 1.0
                cell.commentsButton.layer.borderColor = style.separatorColor.CGColor
                cell.commentsButton.titleLabel?.font = UIFont.systemFontOfSize(11.0)
                
                cell.authorLabel.textColor = style.separatorColor
                cell.authorLabel.font = UIFont.systemFontOfSize(11.0)
                cell.authorLabel.lineBreakMode = .ByTruncatingTail
            }
            
            return cell
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
}
