//
//  LinksViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class LinksViewController: UITableViewController, UIActionSheetDelegate {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 140.0 // This depends on the size of the dynamic text!
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerClass(LinkCell.self, forCellReuseIdentifier: "LinkCell")
        tableView.backgroundColor = style.backgroundColor
        tableView.separatorColor = style.separatorColor
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LinkCell", forIndexPath: indexPath) as LinkCell
        cell.backgroundColor = style.backgroundColor
        cell.contentView.backgroundColor = style.backgroundColor
        cell.selectionStyle = .None
        cell.layoutMargins = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
        
        if indexPath.row == 0 {
            cell.titleLabel.text = "TIL there is a $100 coin that is legal U.S. tender. They weigh1 ounce and are 99.95% platinum. This is the highest face value ever to appear on a U.S. coin."
        } else {
            cell.titleLabel.text = "TIL there is a $100 coin that is legal U.S."
        }
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
        let thumbnailData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("placeholderThumbnail", ofType: "jpg")!)
        let thumbnail = UIImage(data: thumbnailData!, scale: 2.0)
        cell.thumbnailImageView.image = thumbnail
        cell.thumbnailImageView.layer.masksToBounds = true
        cell.thumbnailImageView.layer.cornerRadius = 4.0
        cell.thumbnailImageView.layer.borderWidth = 1.0 / tableView.window!.screen.scale
        cell.thumbnailImageView.layer.borderColor = style.separatorColor.CGColor
        
        cell.commentsButton.setTitle("2000 Comments", forState: .Normal)
        cell.commentsButton.setTitleColor(style.separatorColor, forState: .Normal)
        cell.commentsButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 8.0)
        cell.commentsButton.layer.cornerRadius = 4.0
        cell.commentsButton.layer.borderWidth = 1.0
        cell.commentsButton.layer.borderColor = style.separatorColor.CGColor
        cell.commentsButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        
        cell.authorButton.setTitle("sleepingwithyourmom", forState: .Normal)
        cell.authorButton.setTitleColor(style.separatorColor, forState: .Normal)
        cell.authorButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 8.0)
        cell.authorButton.layer.cornerRadius = 4.0
        cell.authorButton.layer.borderWidth = 1.0
        cell.authorButton.layer.borderColor = style.separatorColor.CGColor
        cell.authorButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        cell.authorButton.titleLabel?.lineBreakMode = .ByTruncatingTail
        return cell
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var moreAction = UITableViewRowAction(style: .Normal, title: "More") { (action, indexPath) -> Void in
            tableView.editing = false
            let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "imgur.com", "AdviceAnimals", "Report", "Hide", "Share")
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
