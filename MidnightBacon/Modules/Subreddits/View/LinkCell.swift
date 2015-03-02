//
//  LinkCell.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

protocol LinkCellDelegate : class {
    func linkCellRequestComments(linkCell: LinkCell)
    func linkCellRequestUpvote(linkCell: LinkCell, selected: Bool)
    func linkCellRequestDownvote(linkCell: LinkCell, selected: Bool)
}

class LinkCell : UITableViewCell {
    struct Measurements {
        let horizontalSpacing = CGFloat(8.0)
        let verticalSpacing = CGFloat(8.0)
        let voteSpacing = CGFloat(8.0)
        let thumbnailSize = CGSize(width: 70.0, height: 70.0)
    }
    
    var delegate: LinkCellDelegate!
    var measurements = Measurements()
    let titleLabel = UILabel()
    let upvoteButton = UIButton()
    let downvoteButton = UIButton()
    let authorLabel = UILabel()
    let commentsButton = UIButton()
    var styled = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(upvoteButton)
        contentView.addSubview(downvoteButton)
        contentView.addSubview(commentsButton)
        
        commentsButton.addTarget(self, action: Selector("commentsAction:"), forControlEvents: .TouchUpInside)
        upvoteButton.addTarget(self, action: Selector("upvoteAction:"), forControlEvents: .TouchUpInside)
        downvoteButton.addTarget(self, action: Selector("downvoteAction:"), forControlEvents: .TouchUpInside)
        
//        titleLabel.layer.borderColor = UIColor.redColor().CGColor
//        titleLabel.layer.borderWidth = 1.0
//        
//        authorLabel.layer.borderColor = UIColor.greenColor().CGColor
//        authorLabel.layer.borderWidth = 1.0
//        
//        commentsButton.layer.borderColor = UIColor.blueColor().CGColor
//        commentsButton.layer.borderWidth = 1.0
//        
//        upvoteButton.layer.borderColor = UIColor.purpleColor().CGColor
//        upvoteButton.layer.borderWidth = 1.0
//        
//        downvoteButton.layer.borderColor = UIColor.orangeColor().CGColor
//        downvoteButton.layer.borderWidth = 1.0
    }
    
    func commentsAction(sender: UIButton) {
        if let strongDelegate = delegate {
            strongDelegate.linkCellRequestComments(self)
        }
    }
    
    func upvoteAction(sender: UIButton) {
        upvoteButton.selected = !upvoteButton.selected
        
        if upvoteButton.selected {
            upvoteButton.layer.borderColor = upvoteButton.titleColorForState(.Selected)?.CGColor
        } else {
            upvoteButton.layer.borderColor = upvoteButton.titleColorForState(.Normal)?.CGColor
        }

        downvoteButton.selected = false
        downvoteButton.layer.borderColor = downvoteButton.titleColorForState(.Normal)?.CGColor

        if let strongDelegate = delegate {
            strongDelegate.linkCellRequestUpvote(self, selected: upvoteButton.selected)
        }
    }
    
    func downvoteAction(sender: UIButton) {
        downvoteButton.selected = !downvoteButton.selected
        
        if downvoteButton.selected {
            downvoteButton.layer.borderColor = downvoteButton.titleColorForState(.Selected)?.CGColor
        } else {
            downvoteButton.layer.borderColor = downvoteButton.titleColorForState(.Normal)?.CGColor
        }

        upvoteButton.selected = false
        upvoteButton.layer.borderColor = upvoteButton.titleColorForState(.Normal)?.CGColor
        
        if let strongDelegate = delegate {
            strongDelegate.linkCellRequestDownvote(self, selected: downvoteButton.selected)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = ""
        authorLabel.text = ""
        
        upvoteButton.selected = false
        downvoteButton.selected = false
        
        upvoteButton.layer.borderColor = upvoteButton.titleColorForState(.Normal)?.CGColor
        downvoteButton.layer.borderColor = downvoteButton.titleColorForState(.Normal)?.CGColor

        delegate = nil
    }
    
    func vote(direction: VoteDirection) {
        if direction == .Upvote {
            upvoteButton.selected = true
            upvoteButton.layer.borderColor = upvoteButton.titleColorForState(.Selected)?.CGColor
        } else if direction == .Downvote {
            downvoteButton.selected = true
            downvoteButton.layer.borderColor = downvoteButton.titleColorForState(.Selected)?.CGColor
        }
    }
}
